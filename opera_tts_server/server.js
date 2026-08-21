const express = require('express');
const fs = require('fs');
const path = require('path');
const textToSpeech = require('@google-cloud/text-to-speech');

const app = express();
app.use(express.json());
app.use('/output', express.static(path.join(__dirname, 'output')));

const client = new textToSpeech.TextToSpeechClient({
  keyFilename: './opera-tts-f6e246af5c24.json',
});

const outputDir = path.join(__dirname, 'output');

if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir);
}

function safeFileName(text) {
  return text
    .toLowerCase()
    .trim()
    .replace(/[<>:"/\\|?*\x00-\x1F]/g, '')
    .replace(/\s+/g, '_')
    .slice(0, 50);
}

app.post('/tts', async (req, res) => {
  try {
    const { word, languageCode } = req.body;

    if (!word || !languageCode) {
      return res.status(400).json({
        error: 'word and languageCode are required',
      });
    }

    const request = {
      input: { text: word },
      voice: {
        languageCode,
      },
      audioConfig: {
        audioEncoding: 'MP3',
      },
    };

    const [response] = await client.synthesizeSpeech(request);

    const safeWord = safeFileName(word);
    const timestamp = Date.now();
    const fileName = `${safeWord}_${languageCode}_${timestamp}.mp3`;
    const filePath = path.join(outputDir, fileName);

    fs.writeFileSync(filePath, response.audioContent, 'binary');

res.json({
  message: 'TTS success',
  saved: fileName,
  path: filePath,
  url: `http://localhost:3000/output/${fileName}`,
});

  } catch (error) {
    console.error(error);
    res.status(500).json({
      error: 'Failed to synthesize speech',
      details: error.message,
    });
  }
});

app.listen(3000, () => {
  console.log('Server running on http://localhost:3000');
});
