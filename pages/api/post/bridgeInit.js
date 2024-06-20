
//dll 로드 되는거

// import { NextApiRequest, NextApiResponse } from 'next';
// import { loadDll } from '../../../lib/bridgeHandler';

// export default function handler(req, res) {
//     try {
//         loadDll();
//         res.status(200).json({ message: 'DLL loaded successfully' });
//     } catch (error) {
//         console.error('Error loading DLL:', error);
//         res.status(500).json({ error: 'Error loading DLL' });
//     }
// }




import { NextApiRequest, NextApiResponse } from 'next';
import { callDllMethod } from '../../../lib/bridgeHandler'

export default async function handler(req, res) {
    console.log('브릿지 인잇')
    if (req.method === 'POST') {
      const { chartCode, hospitalCode, initType} = req.body;
      //const { cellphone, regNum, eventId, jobId, length} = req.body;
      //console.log('API 호출, 파라미터:', { chartCode, hospitalCode, initType });
  
      const payload = {
       chartCode: parseInt(chartCode, 10),
       hospitalCode: String(hospitalCode),
       initType: parseInt(initType, 10),
      // data : {
      //   cellphone : parseInt(cellphone , 10),
      //   regNum : parseInt(regNum , 10) ,
      //   eventId :String(eventId),
      //   jobId : String(jobId) ,
      //  },
      //  length: parseInt(length , 10)
       };
  
      try {
        const result = await callDllMethod(payload);
        res.status(200).json({ result });
        console.log('API 호출, DLL method result:', result);
      } catch (error) {
        console.error('Error calling DLL method:', error);
        res.status(500).json({ error: 'Error calling DLL method' });
      }
    } else {
      res.status(405).json({ error: 'Method not allowed' });
    }
  }

 