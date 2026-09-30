import { access, copyFile, readdir, mkdir, rm } from "node:fs/promises";
import path from "node:path";
import sharp from "sharp";

const inputDirectory = "assets/static/images";
const outputDirectory = "dist/assets/images";
const supportedExtensions = new Set([
  ".avif",
  ".jpeg",
  ".jpg",
  ".png",
  ".tif",
  ".tiff",
  ".webp",
]);

const customFavicon = "assets/static/favicon.svg";
const defaultFavicon = "assets/default/favicon.svg";

await rm(outputDirectory, { recursive: true, force: true });
await mkdir(outputDirectory, { recursive: true });

const images = await findImages(inputDirectory);

for (const input of images) {
  const relative = path.relative(inputDirectory, input);
  const parsed = path.parse(relative);
  const destinationDirectory = path.join(outputDirectory, parsed.dir);
  const output = path.join(destinationDirectory, `${parsed.name}.webp`);

  await mkdir(destinationDirectory, { recursive: true });
  await sharp(input)
    .rotate()
    .resize({ width: 1000, withoutEnlargement: true })
    .webp({ quality: 68 })
    .toFile(output);

  console.log(`${relative} → ${path.relative("dist", output)}`);
}

const faviconSource = await exists(customFavicon) ? customFavicon : defaultFavicon;
await copyFile(faviconSource, "dist/favicon.svg");
await sharp(faviconSource).resize(32, 32).png().toFile("dist/favicon-32.png");
await sharp(faviconSource).resize(180, 180).png().toFile("dist/apple-touch-icon.png");
console.log(`${faviconSource} → favicon files`);

async function findImages(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  const images = [];

  for (const entry of entries) {
    const filename = path.join(directory, entry.name);

    if (entry.isDirectory()) {
      images.push(...await findImages(filename));
    } else if (supportedExtensions.has(path.extname(entry.name).toLowerCase())) {
      images.push(filename);
    }
  }

  return images.sort();
}

async function exists(filename) {
  try {
    await access(filename);
    return true;
  } catch {
    return false;
  }
}
