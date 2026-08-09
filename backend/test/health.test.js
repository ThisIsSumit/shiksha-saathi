const test = require('node:test');
const assert = require('node:assert/strict');

const app = require('../src/app');

test('backend serves health check', async () => {
  const server = app.listen(0);

  try {
    const { port } = server.address();
    const response = await fetch(`http://127.0.0.1:${port}/health`);
    const body = await response.json();

    assert.equal(response.status, 200);
    assert.equal(body.status, 'ok');
    assert.equal(body.service, 'Shiksha Saathi API');
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
});