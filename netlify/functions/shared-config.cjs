const {config, readKeys, response} = require('../lib/shared.cjs');
exports.handler = async event => {
  if (event.httpMethod !== 'GET') return response(405, {error:'Method not allowed'});
  try { readKeys(); } catch { return response(503, {error:'Shared configuration needs the server read keys. Import NEL_THINGSPEAK_READ_KEYS in Netlify and redeploy.'}); }
  return response(200, config);
};
