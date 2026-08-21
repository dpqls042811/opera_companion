const fs = require('fs');
const path = require('path');

const AUDIO_DIR = path.join(__dirname, 'assets', 'audio');

function sanitizeFilename(filename) {
  const ext = path.extname(filename).toLowerCase();
  let base = path.basename(filename, ext);

  // 유니코드 정규화 + 악센트 제거
  base = base.normalize('NFD').replace(/[\u0300-\u036f]/g, '');

  // 소문자
  base = base.toLowerCase();

  // 따옴표 제거
  base = base.replace(/['’`]/g, '');

  // 문장부호 제거
  base = base.replace(/[.,!?;:()"“”$$$${}\-]/g, '');

  // 공백 -> _
  base = base.replace(/\s+/g, '_');

  // 영문/숫자/_ 외 제거
  base = base.replace(/[^a-z0-9_]/g, '');

  // 중복 _ 제거
  base = base.replace(/_+/g, '_');

  // 앞뒤 _ 제거
  base = base.replace(/^_+|_+$/g, '');

  return base + ext;
}

function main() {
  if (!fs.existsSync(AUDIO_DIR)) {
    console.error(`폴더 없음: ${AUDIO_DIR}`);
    return;
  }

  const files = fs.readdirSync(AUDIO_DIR);
  let renamed = 0;

  for (const file of files) {
    const oldPath = path.join(AUDIO_DIR, file);

    if (!fs.statSync(oldPath).isFile()) continue;

    const newName = sanitizeFilename(file);
    const newPath = path.join(AUDIO_DIR, newName);

    if (oldPath === newPath) continue;

    if (fs.existsSync(newPath)) {
      console.log(`[충돌 건너뜀] ${file} -> ${newName}`);
      continue;
    }

    fs.renameSync(oldPath, newPath);
    console.log(`${file} -> ${newName}`);
    renamed++;
  }

  console.log(`\n완료: ${renamed}개 파일 이름 변경`);
}

main();
