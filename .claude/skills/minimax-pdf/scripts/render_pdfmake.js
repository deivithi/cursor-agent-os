#!/usr/bin/env node
/**
 * render_pdfmake.js — Generate PDF from JSON document definition using pdfmake
 *
 * Usage:
 *   node render_pdfmake.js --input doc.json --out output.pdf
 *   node render_pdfmake.js --input doc.json --out output.pdf --open
 *
 * The JSON file must contain a valid pdfmake document definition object.
 * See: https://pdfmake.github.io/docs/0.1/document-definition-object/
 */

const fs = require('fs');
const path = require('path');

// Parse CLI args
const args = process.argv.slice(2);
const getArg = (name) => {
  const idx = args.indexOf(`--${name}`);
  return idx !== -1 && idx + 1 < args.length ? args[idx + 1] : null;
};
const hasFlag = (name) => args.includes(`--${name}`);

const inputPath = getArg('input');
const outputPath = getArg('out') || 'output.pdf';
const shouldOpen = hasFlag('open');

if (!inputPath) {
  console.error('Usage: node render_pdfmake.js --input <doc.json> --out <output.pdf>');
  process.exit(1);
}

async function main() {
  // Dynamically require pdfmake (install check)
  let PdfPrinter;
  try {
    PdfPrinter = require('pdfmake/src/printer');
  } catch {
    console.error('pdfmake not found. Installing...');
    const { execSync } = require('child_process');
    execSync('npm install pdfmake', { stdio: 'inherit' });
    PdfPrinter = require('pdfmake/src/printer');
  }

  // Standard fonts (Roboto bundled with pdfmake)
  const fonts = {
    Roboto: {
      normal: path.join(require.resolve('pdfmake'), '..', '..', 'fonts', 'Roboto', 'Roboto-Regular.ttf'),
      bold: path.join(require.resolve('pdfmake'), '..', '..', 'fonts', 'Roboto', 'Roboto-Medium.ttf'),
      italics: path.join(require.resolve('pdfmake'), '..', '..', 'fonts', 'Roboto', 'Roboto-Italic.ttf'),
      bolditalics: path.join(require.resolve('pdfmake'), '..', '..', 'fonts', 'Roboto', 'Roboto-MediumItalic.ttf'),
    },
  };

  // Read and parse document definition
  const raw = fs.readFileSync(inputPath, 'utf-8');
  const docDefinition = JSON.parse(raw);

  // Apply defaults if not set
  if (!docDefinition.defaultStyle) {
    docDefinition.defaultStyle = { font: 'Roboto', fontSize: 11, lineHeight: 1.4 };
  }
  if (!docDefinition.pageMargins) {
    docDefinition.pageMargins = [60, 60, 60, 60];
  }

  // Create PDF
  const printer = new PdfPrinter(fonts);
  const pdfDoc = printer.createPdfKitDocument(docDefinition);

  // Write to file
  const outDir = path.dirname(outputPath);
  if (outDir && !fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }

  const writeStream = fs.createWriteStream(outputPath);
  pdfDoc.pipe(writeStream);
  pdfDoc.end();

  await new Promise((resolve, reject) => {
    writeStream.on('finish', resolve);
    writeStream.on('error', reject);
  });

  const absPath = path.resolve(outputPath);
  console.log(`✅ PDF generated: ${absPath}`);

  if (shouldOpen) {
    const { exec } = require('child_process');
    const cmd = process.platform === 'win32' ? `start "" "${absPath}"`
      : process.platform === 'darwin' ? `open "${absPath}"`
      : `xdg-open "${absPath}"`;
    exec(cmd);
  }
}

main().catch((err) => {
  console.error('❌ Error:', err.message);
  process.exit(1);
});
