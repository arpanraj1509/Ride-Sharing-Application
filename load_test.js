// Load test for ride-service's /api/v1/rides/request endpoint.
// Run seed_drivers.sh FIRST so there are drivers to match against.
//
// Install k6 (https://k6.io/docs/get-started/installation/), then run:
//   k6 run load_test.js
//
// Tune VUs (concurrent virtual users) and duration below to match what
// you want to claim on your resume, e.g. "20 concurrent users for 30s".

import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 20,          // concurrent virtual users hitting the API
  duration: '30s',  // how long the test runs
  thresholds: {
    // Adjust this to whatever latency you're aiming to prove/report
    http_req_duration: ['p(95)<1000'],
  },
};

// Same bounding box as seed_drivers.sh so pickup/drop points land near
// the seeded drivers.
const MIN_LAT = 12.90;
const MAX_LAT = 13.05;
const MIN_LON = 77.55;
const MAX_LON = 77.70;

function randInRange(min, max) {
  return min + Math.random() * (max - min);
}

export default function () {
  const riderId = `rider:${Math.floor(Math.random() * 100000)}`;

  const payload = JSON.stringify({
    riderId: riderId,
    pickupLatitude: randInRange(MIN_LAT, MAX_LAT),
    pickupLongitude: randInRange(MIN_LON, MAX_LON),
    pickupAddress: 'Load Test Pickup',
    dropLatitude: randInRange(MIN_LAT, MAX_LAT),
    dropLongitude: randInRange(MIN_LON, MAX_LON),
    dropAddress: 'Load Test Drop',
  });

  const params = { headers: { 'Content-Type': 'application/json' } };

  const res = http.post(
    'http://localhost:8083/api/v1/rides/request',
    payload,
    params
  );

  check(res, {
    'status is 200 or 201': (r) => r.status === 200 || r.status === 201,
  });

  sleep(1); // simulate a real gap between a rider's requests
}

// After the run, k6 prints a summary with:
//   http_req_duration ..... avg / min / med / max / p(90) / p(95)
//   http_reqs .............. total requests + requests/sec
// Those two lines are your resume numbers.
