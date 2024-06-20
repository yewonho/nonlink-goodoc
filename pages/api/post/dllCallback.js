export default function handler(req, res) {
    if (req.method === 'POST') {
        const { pjson, nlen } = req.body;
        console.log('Received DLL callback data:', pjson, nlen);
        
        // 콜백 데이터를 처리합니다.
        
        //res.status(200).json({ message: 'Callback data received' });
       res.status(200).json(pjson);
    } else {
        res.status(405).json({ message: 'Method not allowed' });
    }
}