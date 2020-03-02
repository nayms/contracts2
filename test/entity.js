import { sha3 } from './utils/web3'

import {
  extractEventArgs,
  hdWallet,
  ADDRESS_ZERO,
  createPolicy,
} from './utils'

import { events } from '../'
import { ROLES } from '../utils/constants'
import { ensureEtherTokenIsDeployed } from '../migrations/modules/etherToken'
import { ensureAclIsDeployed } from '../migrations/modules/acl'
import { ensureSettingsIsDeployed } from '../migrations/modules/settings'

const IEntityImpl = artifacts.require("./base/IEntityImpl")
const Proxy = artifacts.require('./base/Proxy')
const TestEntityImpl = artifacts.require("./test/TestEntityImpl")
const Entity = artifacts.require("./Entity")
const EntityImpl = artifacts.require("./EntityImpl")
const PolicyImpl = artifacts.require("./PolicyImpl")

contract('Entity', accounts => {
  let acl
  let settings
  let etherToken
  let entityImpl
  let entityProxy
  let entity
  let entityContext

  beforeEach(async () => {
    acl = await ensureAclIsDeployed({ artifacts })
    settings = await ensureSettingsIsDeployed({ artifacts }, acl.address)
    etherToken = await ensureEtherTokenIsDeployed({ artifacts }, acl.address, settings.address)
    entityImpl = await EntityImpl.new(acl.address, settings.address)
    entityProxy = await Entity.new(
      acl.address,
      settings.address,
      entityImpl.address
    )
    // now let's speak to Entity contract using EntityImpl ABI
    entity = await IEntityImpl.at(entityProxy.address)
    entityContext = await entityProxy.aclContext()
  })

  it('must be deployed with a valid implementation', async () => {
    await Entity.new(
      acl.address,
      settings.address,
      ADDRESS_ZERO
    ).should.be.rejectedWith('implementation must be valid')
  })

  it('can be deployed', async () => {
    expect(entityProxy.address).to.exist
  })

  it('can return its implementation version', async () => {
    await entityImpl.getImplementationVersion().should.eventually.eq('v1')
  })

  describe('it can be upgraded', async () => {
    let entityImpl2
    let entityAdminSig
    let entityManagerSig
    let entityRepresentativeSig

    beforeEach(async () => {
      // deploy new implementation
      entityImpl2 = await TestEntityImpl.new()

      // generate upgrade approval signatures
      const implVersion = await entityImpl2.getImplementationVersion()

      await acl.assignRole(entityContext, accounts[1], ROLES.ENTITY_ADMIN)
      entityAdminSig = hdWallet.sign({ address: accounts[1], data: sha3(implVersion) })

      await acl.assignRole(entityContext, accounts[2], ROLES.ENTITY_MANAGER)
      entityManagerSig = hdWallet.sign({ address: accounts[2], data: sha3(implVersion) })

      await acl.assignRole(entityContext, accounts[3], ROLES.ENTITY_REP)
      entityRepresentativeSig = hdWallet.sign({ address: accounts[3], data: sha3(implVersion) })
    })

    it('but not just by anyone', async () => {
      await entityProxy.upgrade(entityImpl2.address, entityAdminSig, { from: accounts[1] }).should.be.rejectedWith('must be admin')
    })

    it('but not with entity manager\'s signature', async () => {
      await entityProxy.upgrade(entityImpl2.address, entityManagerSig).should.be.rejectedWith('must be approved by entity admin')
    })

    it('but not with entity rep\'s signature', async () => {
      await entityProxy.upgrade(entityImpl2.address, entityRepresentativeSig).should.be.rejectedWith('must be approved by entity admin')
    })

    it('but not to an empty address', async () => {
      await entityProxy.upgrade(ADDRESS_ZERO, entityAdminSig).should.be.rejectedWith('implementation must be valid')
    })

    it.skip('but not to the existing implementation', async () => {
      const oldVersion = await entityImpl.getImplementationVersion()
      entityManagerSig = hdWallet.sign({ address: accounts[1], data: sha3(oldVersion) })
      await entityProxy.upgrade(entityImpl.address, entityAdminSig).should.be.rejectedWith('already this implementation')
    })

    it('and points to the new implementation', async () => {
      const result = await entityProxy.upgrade(entityImpl2.address, entityAdminSig).should.be.fulfilled

      expect(extractEventArgs(result, events.Upgraded)).to.include({
        implementation: entityImpl2.address,
        version: 'vTest',
      })
    })
  })

  describe('it can take deposits', () => {
    it('but sender must have enough', async () => {
      await etherToken.deposit({ value: 10 })
      await etherToken.approve(entityProxy.address, 10)
      await entity.deposit(etherToken.address, 11).should.be.rejectedWith('amount exceeds allowance')
    })

    it('but sender must have previously authorized the entity to do the transfer', async () => {
      await etherToken.deposit({ value: 10 })
      await entity.deposit(etherToken.address, 5).should.be.rejectedWith('amount exceeds allowance')
    })

    it('and gets credited with the amount', async () => {
      await etherToken.deposit({ value: 10 })
      await etherToken.approve(entityProxy.address, 10)
      await entity.deposit(etherToken.address, 10).should.be.fulfilled
      await etherToken.balanceOf(entityProxy.address).should.eventually.eq(10)
    })

    describe('and enables subsequent withdrawals', () => {
      beforeEach(async () => {
        await etherToken.deposit({ value: 10 })
        await etherToken.approve(entityProxy.address, 10)
        await entity.deposit(etherToken.address, 10)
      })

      it('but not by just anyone', async () => {
        await entity.withdraw(etherToken.address, 10, { from: accounts[1] }).should.be.rejectedWith('must be entity admin')
      })

      it('by entity admin', async () => {
        await acl.assignRole(entityContext, accounts[1], ROLES.ENTITY_ADMIN)
        await entity.withdraw(etherToken.address, 10, { from: accounts[1] }).should.be.fulfilled
        await etherToken.balanceOf(accounts[1]).should.eventually.eq(10)
        await etherToken.balanceOf(accounts[0]).should.eventually.eq(0)
      })
    })
  })

  describe('policies can be created', () => {
    let policyImpl

    beforeEach(async () => {
      policyImpl = await PolicyImpl.new(acl.address, settings.address)

      await acl.assignRole(entityContext, accounts[1], ROLES.ENTITY_ADMIN)
      await acl.assignRole(entityContext, accounts[2], ROLES.ENTITY_MANAGER)
      await acl.assignRole(entityContext, accounts[3], ROLES.ENTITY_REP)
    })

    it('but not by entity admins', async () => {
      await createPolicy(entity, policyImpl.address, {}, { from: accounts[1] }).should.be.rejectedWith('must be policy creator')
    })

    it('but not by entity reps', async () => {
      await createPolicy(entity, policyImpl.address, {}, { from: accounts[3] }).should.be.rejectedWith('must be policy creator')
    })

    it('by entity managers', async () => {
      const result = await createPolicy(entity, policyImpl.address, {}, { from: accounts[2] }).should.be.fulfilled

      const eventArgs = extractEventArgs(result, events.NewPolicy)

      expect(eventArgs).to.include({
        deployer: accounts[2],
        entity: entityProxy.address,
      })

      await PolicyImpl.at(eventArgs.policy).should.be.fulfilled;
    })

    it('and the entity records get updated accordingly', async () => {
      await entity.getNumPolicies().should.eventually.eq(0)

      const result = await createPolicy(entity, policyImpl.address, {}, { from: accounts[2] })
      const eventArgs = extractEventArgs(result, events.NewPolicy)

      await entity.getNumPolicies().should.eventually.eq(1)
      await entity.getPolicy(0).should.eventually.eq(eventArgs.policy)

      const result2 = await createPolicy(entity, policyImpl.address, {}, { from: accounts[2] })
      const eventArgs2 = extractEventArgs(result2, events.NewPolicy)

      await entity.getNumPolicies().should.eventually.eq(2)
      await entity.getPolicy(1).should.eventually.eq(eventArgs2.policy)
    })

    it('and have their properties set', async () => {
      const startDate = ~~(Date.now() / 1000) + 1

      const result = await createPolicy(entity, policyImpl.address, {
        startDate,
      }, { from: accounts[2] })

      const eventArgs = extractEventArgs(result, events.NewPolicy)

      const policy = await PolicyImpl.at(eventArgs.policy)
      await policy.getStartDate().should.eventually.eq(startDate)

      const proxy = await Proxy.at(eventArgs.policy)
      await proxy.getImplementation().should.eventually.eq(policyImpl.address)
    })

    it('and have the original caller set as property owner', async () => {
      const result = await createPolicy(entity, policyImpl.address, {}, { from: accounts[2] })

      const eventArgs = extractEventArgs(result, events.NewPolicy)

      const policy = await PolicyImpl.at(eventArgs.policy)

      const policyContext = await policy.aclContext()

      await acl.hasRole(policyContext, accounts[2], ROLES.POLICY_OWNER).should.eventually.eq(true)
    })
  })
})
