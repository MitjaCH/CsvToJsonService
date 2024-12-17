function csvToJson(csv: string): any[] {
  const lines = csv.split('\n').filter(line => line.trim() !== '');

  /*
   * Detect the delimeter so it can handle various types of csv formats f.e.:
   * name,age,city
   * name;age;city
   */
  const delimiters = [',', ';', '\t'];
  let delimiter = delimiters.find(d => lines[0].includes(d)) || ',';

  // Detect if there are quotes used in the CSV file f.e.:
  // "name";"age";"city;
  const regex = new RegExp(`(?:^|${delimiter})(?:"([^"]*(?:""[^"]*)*)"|([^"${delimiter}]*))`, 'g');

  // Parse the header line
  const headers: string[] = [];
  lines[0].replace(regex, (_, quoted, unquoted) => {
    headers.push((quoted || unquoted).trim());
    return '';
  });

  // Parse the remaining lines
  const json = lines.slice(1).map(line => {
    const obj: Record<string, string> = {};
    let i = 0;

    line.replace(regex, (_, quoted, unquoted) => {
      obj[headers[i]] = (quoted || unquoted || '').trim();
      i++;
      return '';
    });

    return obj;
  });

  return json;
}
