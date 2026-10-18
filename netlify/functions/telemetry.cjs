const {channels, readKeys, response} = require('../lib/shared.cjs');
exports.handler = async event => {
  if (event.httpMethod !== 'GET') return response(405, {error:'Method not allowed'});
  const channel = event.queryStringParameters?.channel;
  if (typeof channel !== 'string' || !/^\d+$/.test(channel) || !channels.has(channel)) return response(404, {error:'Unknown channel'});
  let keys;
  try { keys = readKeys(); } catch { return response(503, {error:'Server read keys are not configured'}); }
  const ctrl = new AbortController(), timer = setTimeout(() => ctrl.abort(), 8000);
  try {
    const url = new URL('https://api.thingspeak.com/channels/' + channel + '/feeds/last.json');
    url.searchParams.set('api_key', keys[channel]);
    const result = await fetch(url, {signal:ctrl.signal, redirect:'error'});
    if (!result.ok) return response(502, {error:'ThingSpeak read failed; check the server channel configuration'});
    const feed = await result.json();
    if (!feed || typeof feed !== 'object' || !Number.isFinite(Date.parse(feed.created_at))) return response(502, {error:'No timestamped ThingSpeak entry available'});
    const safeFeed = {created_at:feed.created_at, entry_id:feed.entry_id ?? null};
    for (let field=1; field<=8; field++) safeFeed['field'+field] = feed['field'+field] ?? null;
    return response(200, safeFeed, true);
  } catch { return response(502, {error:'ThingSpeak is temporarily unavailable'}); }
  finally { clearTimeout(timer); }
};
