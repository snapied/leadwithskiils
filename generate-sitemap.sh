#!/bin/bash
# generate-sitemap.sh
# macOS-friendly sitemap generator
# Usage:
#   ./generate-sitemap.sh /path/to/site
# Outputs sitemap.xml or sitemap-index (no gzip)

set -euo pipefail

ROOT_DIR="${1:-.}"
OUTPUT_BASENAME="sitemap"
BASE_URL="https://www.leadwithskills.com"

# Exclude patterns
EXCLUDE_PATTERNS=( 
  "*/.git/*" 
  "*/node_modules/*" 
  "*/.DS_Store" 
  "*/generate-sitemap.sh"
  "*/.sh"
  "*/vercel.json"
)

# Allowed file extensions to include
ALLOWED_EXT=( "html" "htm" )

# Defaults for tags
DEFAULT_CHANGEFREQ="monthly"
DEFAULT_PRIORITY="0.5"

# Chunking: keep well under 50k URLs
MAX_URLS_PER_SITEMAP=45000

# Helper function for ISO timestamp
now_iso() { date -u +"%Y-%m-%dT%H:%M:%S.000Z"; }

# Check if python3 is available
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is required but not installed"
    exit 1
fi

# Build find exclude args
find_args=( "$ROOT_DIR" -type f )
for p in "${EXCLUDE_PATTERNS[@]}"; do
    find_args+=( ! -path "$p" )
done

# Collect candidate files
echo "Scanning files in $ROOT_DIR..."
files=()
while IFS= read -r -d '' f; do
    files+=("$f")
done < <(find "${find_args[@]}" -print0 2>/dev/null || find "$ROOT_DIR" -type f ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/.DS_Store" -print0)

if [[ ${#files[@]} -eq 0 ]]; then
    echo "No files found in $ROOT_DIR"
    exit 1
fi

urls=()

for file in "${files[@]}"; do
    # Skip if file doesn't exist (safety check)
    [[ -f "$file" ]] || continue
    
    base="$(basename "$file")"
    # skip hidden files
    if [[ "$base" == .* ]]; then
        continue
    fi

    # get extension (lowercase)
    ext="${file##*.}"
    ext_lc="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"
    include=false
    for a in "${ALLOWED_EXT[@]}"; do
        if [[ "$ext_lc" == "$a" ]]; then include=true; break; fi
    done
    $include || continue

    # compute relative path and encode
    relpath=$(python3 - "$file" "$ROOT_DIR" <<'PYTHON_EOF'
import os
import sys
import urllib.parse

file_path = sys.argv[1]
root_dir = sys.argv[2]

# Get relative path
try:
    rel_path = os.path.relpath(file_path, root_dir).replace(os.path.sep, '/')
except ValueError:
    # Files might be on different drives on Windows, but we're on macOS/Linux
    rel_path = file_path.replace(root_dir, '').lstrip('/').replace(os.path.sep, '/')

# Handle index.html files and clean up extensions
if rel_path == "index.html":
    out_path = ""
elif rel_path.endswith("/index.html"):
    out_path = rel_path[:-len("/index.html")] + "/"
elif rel_path.endswith(".html"):
    out_path = rel_path[:-5]  # Remove .html
elif rel_path.endswith(".htm"):
    out_path = rel_path[:-4]  # Remove .htm
else:
    out_path = rel_path

# URL encode each segment
if out_path:
    segments = out_path.split('/')
    encoded_segments = []
    for seg in segments:
        if seg:  # Skip empty segments
            encoded_segments.append(urllib.parse.quote(seg, safe=''))
        else:
            encoded_segments.append('')
    
    if out_path.endswith('/'):
        encoded_path = "/".join(encoded_segments) + "/"
    else:
        encoded_path = "/".join(encoded_segments)
else:
    encoded_path = ""

print(encoded_path)
PYTHON_EOF
)

    # Build final URL
    if [[ -z "$relpath" ]]; then
        url="${BASE_URL}/"
    else
        # Remove leading slash if present and ensure proper formatting
        relpath="${relpath#/}"
        if [[ -z "$relpath" ]]; then
            url="${BASE_URL}/"
        elif [[ "$relpath" == */ ]]; then
            url="${BASE_URL}/${relpath}"
        else
            url="${BASE_URL}/${relpath}"
        fi
    fi

    # Get last modified time (macOS compatible)
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS version
        lastmod=$(date -u -r "$file" +"%Y-%m-%dT%H:%M:%S.000Z" 2>/dev/null || now_iso)
    else
        # Linux version
        lastmod=$(date -u -d "@$(stat -c %Y "$file" 2>/dev/null)" +"%Y-%m-%dT%H:%M:%S.000Z" 2>/dev/null || now_iso)
    fi

    # determine priority
    priority="$DEFAULT_PRIORITY"
    if [[ "$url" == "${BASE_URL}/" ]]; then
        priority="1.0"
    elif [[ "$url" == "${BASE_URL}/blogs/"* ]]; then
        priority="0.7"
    elif [[ "$url" == *"refund-policy"* || "$url" == *"terms-and-conditions"* || "$url" == *"privacy-policy"* ]]; then
        priority="0.3"
    fi

    urls+=( "$url|$lastmod|$DEFAULT_CHANGEFREQ|$priority" )
done

total=${#urls[@]}
if [[ $total -eq 0 ]]; then
    echo "No files found matching extensions ${ALLOWED_EXT[*]} in $ROOT_DIR"
    exit 1
fi

echo "Found $total URLs. Producing sitemaps..."

# Clean up any existing sitemap files
rm -f "${OUTPUT_BASENAME}"-*.xml "${OUTPUT_BASENAME}.xml"

# chunk into sitemap files
chunk=0
index_entries=()
i=0
while [[ $i -lt $total ]]; do
    chunk=$((chunk+1))
    sitemap_file="${OUTPUT_BASENAME}-${chunk}.xml"
    
    # Create XML header
    cat > "$sitemap_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
EOF

    count=0
    while [[ $i -lt $total && $count -lt $MAX_URLS_PER_SITEMAP ]]; do
        IFS='|' read -r url lastmod changefreq priority <<< "${urls[$i]}"
        
        # Escape XML special characters in URL
        url_escaped=$(echo "$url" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&apos;/g')
        
        cat >> "$sitemap_file" <<EOF
  <url>
    <loc>${url_escaped}</loc>
    <lastmod>${lastmod}</lastmod>
    <changefreq>${changefreq}</changefreq>
    <priority>${priority}</priority>
  </url>
EOF
        i=$((i+1))
        count=$((count+1))
    done
    
    echo "</urlset>" >> "$sitemap_file"

    index_entries+=( "$sitemap_file" )
    echo "Wrote $sitemap_file ($count URLs)"
done

# if only one sitemap file, move/rename to sitemap.xml
if [[ ${#index_entries[@]} -eq 1 ]]; then
    mv -f "${index_entries[0]}" "${OUTPUT_BASENAME}.xml"
    echo "Final sitemap: ${OUTPUT_BASENAME}.xml"
    echo "Add to robots.txt: Sitemap: ${BASE_URL}/sitemap.xml"
else
    # create sitemap index
    sitemap_index="${OUTPUT_BASENAME}-index.xml"
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > "$sitemap_index"
    echo "<sitemapindex xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">" >> "$sitemap_index"
    
    for s in "${index_entries[@]}"; do
        fname="$(basename "$s")"
        cat >> "$sitemap_index" <<EOF
  <sitemap>
    <loc>${BASE_URL}/${fname}</loc>
    <lastmod>$(now_iso)</lastmod>
  </sitemap>
EOF
    done
    
    echo "</sitemapindex>" >> "$sitemap_index"
    echo "Wrote ${sitemap_index}"
    echo "Add to robots.txt: Sitemap: ${BASE_URL}/${sitemap_index}"
fi

echo "Done. Total URLs processed: $total"