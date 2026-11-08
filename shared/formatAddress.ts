/** Single-line street + city for tables and print (no leading comma when street is empty). */
export function formatStreetCity(address: string, city: string): string {
  const street = address.trim();
  const c = city.trim();
  if (street && c) return `${street}, ${c}`;
  return street || c || "—";
}
