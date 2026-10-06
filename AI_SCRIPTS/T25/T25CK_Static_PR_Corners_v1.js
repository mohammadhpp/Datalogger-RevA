// T25CK static conditional screen; run with Node. Does not modify vendor models.
// Reproduces executed32 endpoints; no TCR/ripple/dynamic/hysteresis qualification.
const rows=[];
for(const tr of [.99,1.01])for(const br of [.995,1.005])
for(const ref of [2.4498,2.5502])for(const offset of [-.04,.04])
for(const leak of [-1e-7,1e-7]){
 const rt=2000*tr,rb=10000*br,k=rb/(rt+rb);
 rows.push({rt,rb,ref,offset,leak,trip:(ref+offset)/k+leak*rt});
}
const low=Math.min(...rows.map(r=>r.trip)),high=Math.max(...rows.map(r=>r.trip));
console.log(JSON.stringify({scope:"CONDITIONAL_STATIC_ONLY_NO_HARDWARE_PASS",
 count:rows.length,trip_min_V:low,trip_max_V:high,
 USB_3_185094_attach_margin_V:3.185094-high,rows},null,2));
