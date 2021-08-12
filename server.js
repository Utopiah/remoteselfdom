const fs = require('fs');
const { exec, execSync } = require('child_process');
const express = require('express');

var https = require('https');

var privateKey  = fs.readFileSync('localhttps.key', 'utf8');
var certificate = fs.readFileSync('localhttps.cert', 'utf8');

var credentials = {key: privateKey, cert: certificate};

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

const app = express();
const datapath = '/usr/src/bot/selfdom/exp_prosoc/expBatch/data/'
app.use('/data', express.static(datapath))
app.get('/remote', (req, res) => {
	// no queue system here
	// nodemon kill child processes so saving will kill pending jobs (which is convenient for testing)
	if ( req.query.seed && req.query.prosoc) {
		let seed = Number( req.query.seed )
		let prosoc = Number( req.query.prosoc )
		q.push( { seed, prosoc } ) // should instead pass all parameters
		// could be interesting to add a parameter for cache busting
		res.json( `exp_soc-${prosoc}_out_s-${seed}_dyn` )
	} else {
		res.json('missing parameter')
	}
});
app.post('/directxml', (req, res) => {
	res.json('Argos');
});
app.get('/', (req, res) => {
	res.json('Argos web discovery');
});
app.get('/processedindex', (req, res) => {
	res.json(fs.readdirSync(datapath));
});
app.get('/currentproc', (req, res) => {
	exec('ps --no-headers -C argos3', (e,stdo,stde) => res.json(stdo.split('\n').slice(0, -1) ) )
});
app.get('/jobs', (req, res) => {
	res.json(jobsStatus);
});

var q = []
var jobsStatus = []
var processing = 0 // would be cleaner to generate an array of tasks with uuid 
const maxTasks = 6

function processNext(){
	//console.log("q check", q)
	//console.log(!q.length, processing, ">=", maxTasks, processing >= maxTasks ) 
	if (!q.length || processing >= maxTasks ) return

	let t = q.shift()
	console.log("processing", t)
	processing++
	let prosoc = t.prosoc
	let seed = t.seed
	let filename = `exp_soc-${prosoc}_out_s-${seed}_dyn`
	if(!fs.existsSync(datapath+filename)){
		exec( `cd /usr/src/bot/selfdom/exp_prosoc/ && ./runExpBatch.sh ${seed} ${prosoc}` ,
			(e,stdo,stde) => {
				jobsStatus.push({"status": "done", time: Date.now(), output: stdo, error: stde}) 
				processing--
			})
	} else {
		processing--
	}
}
setInterval( processNext, 50 )

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);

var httpsServer = https.createServer(credentials, app);
httpsServer.listen(8443);
