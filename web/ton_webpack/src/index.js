import { Buffer } from 'buffer';
window.Buffer = Buffer;

const ton = require('@ton/ton');
window.ton = ton; // Expose it to the global window object for browser use