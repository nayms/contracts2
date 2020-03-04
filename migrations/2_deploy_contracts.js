const EntityImpl = artifacts.require("./EntityImpl")
const PolicyImpl = artifacts.require("./PolicyImpl")
const EntityDeployer = artifacts.require("./EntityDeployer")

const { ensureAclIsDeployed } = require('./modules/acl')
const { ensureMarketIsDeployed } = require('./modules/market')
const { ensureSettingsIsDeployed } = require('./modules/settings')
const { ensureEtherTokenIsDeployed } = require('./modules/etherToken')
const { ensureEntityDeployerIsDeployed } = require('./modules/entityDeployer')

module.exports = async deployer => {
  const acl = await ensureAclIsDeployed({ deployer, artifacts, logger: true })
  const settings = await ensureSettingsIsDeployed({ deployer, artifacts, logger: true }, acl.address)
  await ensureEtherTokenIsDeployed({ deployer, artifacts, logger: true }, acl.address, settings.address)
  await ensureMarketIsDeployed({ deployer, artifacts, logger: true }, settings.address)

  const entityImpl = await deployer.deploy(EntityImpl, acl.address, settings.address)

  await ensureEntityDeployerIsDeployed({ deployer, artifacts, logger: true }, acl.address, settings.address, entityImpl.address)

  await deployer.deploy(PolicyImpl, acl.address, settings.address)
}
