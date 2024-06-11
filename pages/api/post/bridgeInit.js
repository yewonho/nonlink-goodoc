// import {initializeDll, callDllMethod} from '../../../lib/bridgeHandler'

// export default async (req, res) => {
//   if (req.method !== 'POST') {
//     return res.status(405).json({ message: 'Only POST requests are allowed' });
//   }

//   try {
//     initializeDll();
//     const result = await callDllMethod(req.body);
//     console.log('DLL Method Result:', result);
//     res.status(200).json(result);
//   } catch (error) {
//     console.error('Error calling DLL method:', error);
//     res.status(500).json({ error: error.message });
//   }

//   //return res.status(200).json(result);
// };


import { NextApiRequest, NextApiResponse } from 'next';
import { loadDll } from '../../../lib/bridgeHandler';

export default function handler(req, res) {
    try {
        loadDll();
        res.status(200).json({ message: 'DLL loaded successfully' });
    } catch (error) {
        console.error('Error loading DLL:', error);
        res.status(500).json({ error: 'Error loading DLL' });
    }
}
