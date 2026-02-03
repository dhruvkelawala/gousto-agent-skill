#!/bin/bash
# recipe.sh - Get full recipe details with ingredients and steps

set -e

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <recipe-slug>"
    echo "Example: $0 honey-soy-chicken-with-noodles"
    echo ""
    echo "Find slugs using: ./search.sh <term>"
    exit 1
fi

slug="$1"
API_URL="https://gousto.vfjr.dev/api/recipes/slug/${slug}"

response=$(curl -sS --fail "$API_URL" 2>/dev/null) || {
    echo "Error: Failed to fetch recipe '$slug'"
    echo "Recipe may not exist or API may be unavailable."
    exit 1
}

# Output as clean JSON with the important fields
echo "$response" | jq '{
    title,
    slug,
    rating,
    prep_time,
    basic_ingredients: (.basic_ingredients // []),
    ingredients: [.ingredients[]? | "\(.amount // "") \(.ingredient.name)"],
    steps: [.instruction_steps | sort_by(.order)[]? | {
        order,
        text: (.text | gsub("<[^>]+>"; "") | gsub("&nbsp;"; " ") | gsub("&amp;"; "&") | gsub("&lt;"; "<") | gsub("&gt;"; ">"))
    }]
}'
