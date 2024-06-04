import {callDllMethod} from '../../../lib/bridgeHandler'

export default async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Only POST requests are allowed' });
  }

  try {
    const result = await callDllMethod(req.body);
    console.log('DLL Method Result:', result);
    res.status(200).json(result);
  } catch (error) {
    console.error('Error calling DLL method:', error);
    res.status(500).json({ error: error.message });
  }

  //return res.status(200).json(result);
};
