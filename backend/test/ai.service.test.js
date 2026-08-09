const test = require('node:test');
const assert = require('node:assert/strict');

const { parseAndNormalizeJsonResponse, normalizeTextResponse } = require('../src/modules/ai/ai.service');

test('parses markdown-wrapped JSON and preserves text content', () => {
  const input = `Here is the lesson plan:\n\n\`\`\`json\n{"title":"Understanding Fractions with Real-Life Examples","objectives":["Identify fractions of a whole using pictures"],"materials":["Paper strips"]}\n\`\`\`\n`;

  const result = parseAndNormalizeJsonResponse(input);

  assert.deepEqual(result, {
    title: 'Understanding Fractions with Real-Life Examples',
    objectives: ['Identify fractions of a whole using pictures'],
    materials: ['Paper strips'],
  });
});

test('normalizes text output while preserving meaningful words and capitalization', () => {
  const input = 'Hello\n\nmy name is   Sumit.\nPlease explain clearly.';

  assert.equal(normalizeTextResponse(input), 'Hello my name is Sumit. Please explain clearly.');
});
