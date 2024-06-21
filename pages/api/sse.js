let clients = [];

function eventsHandler(req, res) {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    res.setHeader('Access-Control-Allow-Origin', '*'); // 필요한 경우 도메인을 명시
    res.flushHeaders();

    clients.push(res);
    console.log("Client connected. Total clients:", clients.length);

    req.on('close', () => {
        clients = clients.filter(client => client !== res);
        console.log("Client disconnected. Total clients:", clients.length);
    });
}

export default function handler(req, res) {
    if (req.method === 'GET') {
        return eventsHandler(req, res);
    } else {
        res.status(405).json({ message: 'Method not allowed' });
    }
}

export function sendEvent(data) {
    console.log("sse sendEvent", data);
    clients.forEach(client => {
        console.log("클라이언트 write", data);
        client.write(`data: ${JSON.stringify(data)}\n\n`);
    });
}
