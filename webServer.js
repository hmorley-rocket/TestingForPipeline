import express from 'express';
const port = 65431;

// Set up server
const app = express();
const webRoot = './';
app.use(express.static(webRoot));
app.listen(port);

