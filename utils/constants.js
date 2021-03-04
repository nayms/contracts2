const { keccak256 } = require('./functions')

export const ADDRESS_ZERO = '0x0000000000000000000000000000000000000000'
export const BYTES32_ZERO = '0x0000000000000000000000000000000000000000000000000000000000000000'

exports.ROLES = {}
exports.ROLEGROUPS = {}
exports.SETTINGS = {}

;[
  'APPROVED_USER',
  'PENDING_UNDERWRITER',
  'PENDING_BROKER',
  'PENDING_INSURED_PARTY',
  'PENDING_CLAIMS_ADMIN',
  'UNDERWRITER',
  'CAPITAL_PROVIDER',
  'BROKER',
  'INSURED_PARTY',
  'CLAIMS_ADMIN',
  'ENTITY_ADMIN',
  'ENTITY_MANAGER',
  'ENTITY_REP',
  'POLICY_OWNER',
  'POLICY_CREATOR',
  'SYSTEM_ADMIN',
  'SYSTEM_MANAGER',
  'UNDERWRITER',
].forEach(r => {
  exports.ROLES[r] = keccak256(`ROLE_${r}`)
})

;[
  'APPROVED_USERS',
  'CAPITAL_PROVIDERS',
  'POLICY_CREATORS',
  'BROKERS',
  'INSURED_PARTYS',
  'CLAIMS_ADMINS',
  'ENTITY_ADMINS',
  'ENTITY_MANAGERS',
  'ENTITY_REPS',
  'POLICY_OWNERS',
  'SYSTEM_ADMINS',
  'SYSTEM_MANAGERS',
  'TRADERS',
  'UNDERWRITERS',
].forEach(r => {
  exports.ROLEGROUPS[r] = keccak256(`ROLEGROUP_${r}`)
})


;[
  'MARKET',
  'ETHER_TOKEN',
  'ENTITY_IMPL',
  'POLICY_IMPL',
  'ENTITY_DEPLOYER',
  'NAYMS_ENTITY',
].forEach(r => {
  exports.SETTINGS[r] = keccak256(`SETTING_${r}`)
})

