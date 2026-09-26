#!/bin/bash
# Seeds N fake drivers scattered across a Bangalore-sized bounding box
# into location-service, so your matching tests reflect real density
# instead of 3 hand-picked points.
#
# Usage: ./seed_drivers.sh [num_drivers]
# Example: ./seed_drivers.sh 500

BASE_URL="http://localhost:8082/api/v1/locations/drivers/update"
NUM_DRIVERS=${1:-500}

# Rough bounding box around central Bangalore (~15km across)
MIN_LAT=12.90
MAX_LAT=13.05
MIN_LON=77.55
MAX_LON=77.70

echo "Seeding $NUM_DRIVERS drivers into $BASE_URL ..."

SUCCESS=0
FAIL=0

for i in $(seq 1 "$NUM_DRIVERS"); do
  LAT=$(awk -v min="$MIN_LAT" -v max="$MAX_LAT" -v seed="$i" \
    'BEGIN{srand(seed*97+1); printf "%.6f", min+rand()*(max-min)}')
  LON=$(awk -v min="$MIN_LON" -v max="$MAX_LON" -v seed="$i" \
    'BEGIN{srand(seed*131+7); printf "%.6f", min+rand()*(max-min)}')

  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL" \
    -H "Content-Type: application/json" \
    -d "{\"driverId\": \"driver:$i\", \"latitude\": $LAT, \"longitude\": $LON}")

  if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "201" ]]; then
    SUCCESS=$((SUCCESS+1))
  else
    FAIL=$((FAIL+1))
    echo "driver:$i failed with HTTP $HTTP_CODE"
  fi

  # simple progress indicator every 50 drivers
  if (( i % 50 == 0 )); then
    echo "  ...seeded $i/$NUM_DRIVERS"
  fi
done

echo ""
echo "Done. Success: $SUCCESS, Failed: $FAIL"
echo ""
echo "Verify in Redis with:"
echo "  docker exec -it redis-geo redis-cli"
echo "  ZCARD drivers:locations"
echo "  GEORADIUS drivers:locations 12.9716 77.5946 5 km"
