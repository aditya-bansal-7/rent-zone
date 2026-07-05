// Quick test of YCE v3 API — uses a real product garment URL from Cloudinary
// Run: node test-yce.mjs

const BASE_URL = 'https://yce-api-01.makeupar.com/s2s/v3.0/task/cloth';
const API_KEY = 'sk-IsBVy7BoHZdDyrSJaeTiIGtDF7kDGBfXAlRYoFC5asKi482bw_adYUn9jDeZWnT9';

const HEADERS = {
  'Content-Type': 'application/json',
  Authorization: `Bearer ${API_KEY}`,
};

// Test person image — a publicly accessible full-body photo
const PERSON_URL =
  'https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?w=512&q=80';

// Test garment image — from your Cloudinary products folder
const GARMENT_URL =
  'https://res.cloudinary.com/denvklxo0/image/upload/v1777412267/rentzone/products/vhpv5rdgihcekzv4nwf0.jpg';

const sleep = ms => new Promise(r => setTimeout(r, ms));

async function startTask() {
  const res = await fetch(BASE_URL, {
    method: 'POST',
    headers: HEADERS,
    body: JSON.stringify({
      src_file_url: PERSON_URL,
      ref_file_url: GARMENT_URL,
      garment_category: 'auto',
    }),
  });
  const json = await res.json();
  console.log('[start] status:', res.status, '| response:', JSON.stringify(json, null, 2));
  if (!res.ok) throw new Error('Start failed: ' + res.status);
  const taskId = json?.data?.task_id;
  if (!taskId) throw new Error('No task_id in response');
  return taskId;
}

async function pollTask(taskId, { intervalMs = 2000, maxAttempts = 60 } = {}) {
  const pollURL = `${BASE_URL}/${encodeURIComponent(taskId)}`;
  for (let i = 1; i <= maxAttempts; i++) {
    await sleep(intervalMs);
    const res = await fetch(pollURL, { headers: HEADERS });
    const json = await res.json();
    const status = json?.data?.task_status;
    console.log(`[poll] attempt ${i} — status: ${status}`);
    if (status === 'success') {
      console.log('[poll] Results:', JSON.stringify(json?.data?.results, null, 2));
      return json;
    }
    if (status === 'error' || status === 'failed') {
      throw new Error('Task failed: ' + JSON.stringify(json));
    }
  }
  throw new Error('Timed out polling');
}

(async () => {
  try {
    console.log('Starting YCE v3 virtual try-on test...\n');
    const taskId = await startTask();
    console.log('\nTask ID:', taskId, '\nPolling...\n');
    const result = await pollTask(taskId);
    console.log('\n✅ Final result:\n', JSON.stringify(result, null, 2));
  } catch (e) {
    console.error('\n❌ Error:', e.message);
    process.exitCode = 1;
  }
})();
