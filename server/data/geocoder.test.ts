import { isPlausiblePaCoordinate, normalizeAddressFields, normalizeCsvCoordinates } from "./geocoder.js";
import { formatStreetCity } from "../../shared/formatAddress.js";

const split = normalizeAddressFields("100 Market St, West Chester, PA", "", "");
if (split.street !== "100 Market St" || split.city !== "West Chester") {
  throw new Error(`Expected street/city split, got ${JSON.stringify(split)}`);
}

const leadingComma = normalizeAddressFields(", West Chester", "", "");
if (leadingComma.street !== "" || leadingComma.city !== "West Chester") {
  throw new Error(`Leading comma fix failed: ${JSON.stringify(leadingComma)}`);
}

if (formatStreetCity("", "West Chester") !== "West Chester") {
  throw new Error("formatStreetCity should not lead with comma");
}
if (formatStreetCity("100 Main", "West Chester") !== "100 Main, West Chester") {
  throw new Error("formatStreetCity combined line failed");
}

if (!isPlausiblePaCoordinate(39.95, -75.16)) throw new Error("Philly coords should be valid");
if (isPlausiblePaCoordinate(-75.16, 39.95)) throw new Error("Swapped coords should not validate as lat/lng");
const swapped = normalizeCsvCoordinates(-75.165, 39.953);
if (!swapped.valid || !swapped.swapped || swapped.lat !== 39.953) {
  throw new Error(`Swap correction failed: ${JSON.stringify(swapped)}`);
}

console.log("Geocoder address tests passed.");
