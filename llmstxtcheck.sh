#!/usr/bin/env bash

# Check input and print help as needed
if [ -z "$1" ]; then
  echo "Error: First argument is missing."
  echo "Usage: ./llmstxtcheck.sh base_url [output_filename]"
  echo "The page 'https://{base_url}/llms.txt' will be fetched all 404'd URLs will be save to output_filename.txt or llms.txt."
  exit 1
fi

# Assign optional filename or default
if [ -x "$2" ]; then
  output_filename="llms.txt"
else
  output_filename=$2
fi

# Download the file and extract all URLs
echo "Loading https://$1/llms.txt..."
urls=$(curl -fsSL https://$1/llms.txt | grep -Eo 'https?://[^) ]+')
total=$(echo "$urls" | wc -l)
count=0

echo "Checking $total URLs for 404 errors..."
echo

# Loop through each URL and check HTTP status
failcount=0
echo "$urls" | while read -r url; do
  count=$((count + 1))
  code=$(curl -o /dev/null -s -w "%{http_code}" "$url")
  printf "[%3d/%3d] %s -> %s\n" "$count" "$total" "$url" "$code"
  if [ "$code" = "404" ]; then
    echo "❌ 404: $url" >> "$output_filename" + ".txt"
    failcount=$((failcount + 1))
  fi
done

echo
echo "Done. Found $failcount failed URLs. Any 404 URLs are saved in $output_filename.txt"