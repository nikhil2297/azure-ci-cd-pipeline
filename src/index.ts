import express, { Request, Response } from 'express';

const app = express();
const port = 3000;

app.get('/', (req: Request, res: Response) => {
  res.send('Hello, Nikhil Lohar this side. Welcome to my first Node.js app!');
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});