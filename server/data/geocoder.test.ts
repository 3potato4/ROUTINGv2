import { normalizeAddressFields } from "./geocoder.js";
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

console.log("Geocoder address tests passed.");
