const fs = require('fs');
const path = require('path');
const textToSpeech = require('@google-cloud/text-to-speech');

// 구글 클라우드 연결
const client = new textToSpeech.TextToSpeechClient({
  keyFilename: './opera-tts-f6e246af5c24.json',
});

const outputDir = path.join(__dirname, 'output');
if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir);

// 💡 [핵심 수정] 파일명 생성 규칙 보강 (작은따옴표, 특수문자 완전 제거)
function safeFileName(text) {
  return text.toLowerCase().trim()
    .replace(/'/g, '')             // 작은따옴표 삭제
    .replace(/’/g, '')             // 다른 형태의 작은따옴표 삭제
    .replace(/[<>:"/\\|?*\x00-\x1F]/g, '') // 파일명 금지 문자 삭제
    .replace(/\s+/g, '_')          // 공백을 언더바(_)로
    .slice(0, 50);
}

// 아리아 JSON 파일들이 모여있는 폴더 경로
const dataFolder = path.join(__dirname, '../assets/data'); 

async function processJsonFiles(dir) {
  const files = fs.readdirSync(dir);

  for (const file of files) {
    const fullPath = path.join(dir, file);
    
    if (fs.statSync(fullPath).isDirectory()) {
      await processJsonFiles(fullPath); 
    } else if (file.endsWith('.json')) {
      const rawData = fs.readFileSync(fullPath, 'utf8');
      const ariaData = JSON.parse(rawData);

      if (!ariaData.lines || !Array.isArray(ariaData.lines)) {
        console.log(`⏭️ [${file}] 건너뜀 (가사 데이터가 아님)`);
        continue;
      }

      console.log(`\n📄 [${file}] 분석 중...`);
      const languageCode = ariaData.languageCode || 'de';

      for (const line of ariaData.lines) {
        if (!line.vocab) continue;

        const vocabLines = line.vocab.split('\n').map(v => v.trim()).filter(v => v.length > 0);
        for (const vLine of vocabLines) {
          const eqIndex = vLine.indexOf('=');
          const word = eqIndex === -1 ? vLine : vLine.substring(0, eqIndex).trim();
          
          if (!word) continue;

          await downloadTTS(word, languageCode);
        }
      }
    }
  }
}

async function downloadTTS(word, languageCode) {
  const safeWord = safeFileName(word);
  const fileName = `${safeWord}_${languageCode}.mp3`;
  const filePath = path.join(outputDir, fileName);

  if (fs.existsSync(filePath)) {
    return;
  }

  console.log(`⬇️ 다운로드 중: ${word} -> ${fileName}`);
  try {
    const request = {
      input: { text: word },
      voice: { languageCode: languageCode === 'it' ? 'it-IT' : 'de-DE' }, // 언어코드 명시
      audioConfig: { audioEncoding: 'MP3' },
    };
    const [response] = await client.synthesizeSpeech(request);
    fs.writeFileSync(filePath, response.audioContent, 'binary');
    
    await new Promise(resolve => setTimeout(resolve, 200)); 
  } catch (error) {
    console.error(`❌ [${word}] 오류 발생:`, error.message);
  }
}

console.log('🚀 오디오 일괄 다운로드를 시작합니다...');
processJsonFiles(dataFolder).then(() => {
  console.log('\n✅ 모든 단어의 mp3 다운로드가 완료되었습니다!');
});