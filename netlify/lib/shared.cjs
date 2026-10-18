const config = require('../shared-dashboard.json');

const channels = new Set([...config.data.inverters, ...config.data.gateways].map(d => String(d.channelId)));
function readKeys() {
  let keys;
  try { keys = JSON.parse(process.env.NEL_THINGSPEAK_READ_KEYS || 'null'); } catch { throw Error('CONFIG'); }
  if (!keys || Array.isArray(keys) || typeof keys !== 'object') throw Error('CONFIG');
  for (const id of channels) {
    if (typeof keys[id] !== 'string' || !/^[a-zA-Z0-9]{16}$/.test(keys[id])) throw Error('CONFIG');
  }
  return keys;
}
function response(statusCode, body, cache = false) {
  return {statusCode, headers:{'Content-Type':'application/json; charset=utf-8', 'Cache-Control':cache ? 'public, max-age=5, s-maxage=10' : 'no-store', 'X-Content-Type-Options':'nosniff'}, body:JSON.stringify(body)};
}
module.exports = {config, channels, readKeys, response};
