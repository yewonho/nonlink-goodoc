import { addClient, removeClient, getClients } from '../../lib/GlobalState';

export const config = {
  runtime: 'edge',
};

export function sendDataToClients(data) {
  const clients = getClients();
  console.log("Entering sendDataToClients, clients length:", clients.length);
  clients.forEach((client, index) => {
    console.log(`Sending data to client ${index}:`, data);
    try {
      client.controller.enqueue(`data: ${JSON.stringify(data)}\n\n`);
      console.log(`Data sent successfully to client ${index}`);
    } catch (error) {
      console.error(`Error sending data to client ${index}:`, error);
    }
  });
  console.log("Finished sendDataToClients");
}

export default async function handler(request) {
  if (request.method === 'GET') {
    console.log("New SSE connection request received");
    const stream = new ReadableStream({
      start(controller) {
        const clientId = Date.now();
        const client = {
          id: clientId,
          controller
        };
        addClient(client);

        // Send an initial message to trigger onopen
        controller.enqueue(`data: ${JSON.stringify({type: 'connection', status: 'opened'})}\n\n`);

        request.signal.addEventListener('abort', () => {
          removeClient(clientId);
        });
      },
    });

    return new Response(stream, {
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      }
    });
  } else {
    return new Response('Method Not Allowed', { status: 405 });
  }
}
