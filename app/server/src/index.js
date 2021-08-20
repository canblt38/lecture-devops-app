const path = require( 'path' );

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const dbClientInstance_ = require('./db/mongo.js');
const todoRoutes = require('./routes/todo');
const userRoutes = require('./routes/user');
const errorRoutes = require('./routes/error');
const envRoute = require('./routes/env.js');
// https://stackabuse.com/nodejs-application-monitoring-with-prometheus-and-grafana/
const client = require('prom-client');
const register = new client.Registry();
client.collectDefaultMetrics({
    app: 'node-application-monitoring-app',
    prefix: 'node_',
    timeout: 10000,
    gcDurationBuckets: [0.001, 0.01, 0.1, 1, 2, 5],
    register
});

let cookieParser = require('cookie-parser');

const app = express();
const port = process.env.PORT || 5000;

const corsOptions = {
    origin: `http://localhost:${ port }`,
    credentials: true
};

app.use(express.json());
app.use(cors(corsOptions));

app.use(cookieParser());

/* app.use(helmet());
app.use(helmet.contentSecurityPolicy({
    directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self' 'unsafe-inline'"],
        scriptSrc: ["'self' 'unsafe-inline' 'unsafe-eval'"]
    }
})); */

app.use(todoRoutes);
app.use(userRoutes);
app.use('/', express.static(path.join(__dirname, `../public`)));
// IMPORTANT: Educational purpose only! Possibly exposes sensitive data.
app.use(envRoute);
// NOTE: must be last one, because is uses a wildcard (!) that behaves aa
// fallback and catches everything else
app.use(errorRoutes);


// Create a custom histogram metric
const httpRequestTimer = new client.Histogram({
    name: 'http_request_duration_seconds',
    help: 'Duration of HTTP requests in seconds',
    labelNames: ['method', 'route', 'code'],
    buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10] // 0.1 to 10 seconds
  });

  // Register the histogram
  register.registerMetric(httpRequestTimer);

// Prometheus metrics route
app.get('/metrics', async (req, res) => {
    // Start the HTTP request timer, saving a reference to the returned method
    const end = httpRequestTimer.startTimer();
    // Save reference to the path so we can record it when ending the timer
    const route = req.route.path;

    res.setHeader('Content-Type', register.contentType);
    res.send(await register.metrics());

    // End timer and add labels
    end({ route, code: res.statusCode, method: req.method });
  });


(async function main(){
    try{
        await new Promise( (__ful, rej__ )=>{
            app.listen(port, function(){
                console.log( `ToDo server is up on port ${ port }`);
                __ful();
            }).on( 'error', rej__);
        });

        process.on( 'SIGINT', ()=>{
            process.exit( 2 );
        });
    }catch( err ){
        console.error( err );
        process.exit( 1 );
    }
})();
