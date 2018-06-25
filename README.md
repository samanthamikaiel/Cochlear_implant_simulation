# Cochlear_implant_simulation

This code employs a series of steps to seperate a sound sample into 8
frequency channels, which are then used to reconstruct the original
signal using Noise-bands filtered at each channel frequency, in order to
accurately mimic the inputs to cochlear implant.

First the signal read and pre-emphasized to reduce noise components. 
Next 8 bandpass filters are applied to the signal in turn, so that the
signal is separated into 8 frequency bands. Each signal is rectified and
Lowpass filtered at 400Hz cutoff frequency to extract each channels
envelope.

For the reconstruction of the signal, a similar step is taken using a
white noise signal; it is bandpassed into the same 8 frequency bands, and
each white noise frequency band is multiplied with the corresponding
envelopes extracted in the last step. Signal reconstruction is complete
when every envelope-weighted channel is summed. This sum is also given a
gain factor to correct the attenuation that resulted from the process.
