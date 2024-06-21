import { sendEvent } from '../sse';

export default function handler(req, res) {
    if (req.method === 'POST') {
        const { pjson, nlen } = req.body;
        console.log('Received DLL callback data:', pjson, nlen);
        
        // SSE를 통해 클라이언트로 전송
        sendEvent({ pjson });
        
       // res.status(200).json({ message: 'Callback data received' });
        res.status(200).json({ pjson , nlen });
    } else {
        res.status(405).json({ message: 'Method not allowed' });
    }
}
