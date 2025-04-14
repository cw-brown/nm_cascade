# Transfer System Cascade
Automatically divide complex S-parameter respones into a black-box network. The Transfer System Cascade (TSC) algorithm is the first step in a generalized algorithm for the inverse design of arbitrary microwave circuits. The entire program is written in MATLAB.

## Download
The most recent files can be found in the releases tab. The program can be run from the *synthesize.mlx* file. This live script has everything you need to begin generating black-box networks. Two example .s2p files are provided: a 3rd order lowpass filter, and a 3rd order bandpass filter. 

TSC was written using MATLAB R2024b. It will NOT work in version earlier than R2024b. There is no guarantee that the code will continue to work for later versions of MATLAB. 

The following toolboxes are necessary to run the code:
1. Control Systems Toolbox
2. Optimization Toolbox
3. Signal Processing Toolbox
4. RF Toolbox
5. Parallel Computing Toolbox (optional, only for parallel computing)

## How It Works
A complex microwave network can have many features within the frequency domain [1]. The inverse design problem is to create a physical circuit that recreates this frequency response. Since the algorithm has no proconceived ideas on what a "correct" design is, inverse design can produce optimal results beyond what humans can create. 

However, the full inverse problem may be too computationally difficult (or impossible), especially for very large and complex inputs. The TSC algorithm attempts to reduce this complexity by dividing the problem into smaller sub-problems. The first step is to create an n by m grid of black-box networks. We don't particularly care what these boxes look like, and instead only focus on the total response. To produce a cascaded S-parameter network with arbitrary connections, the approach from [2] is used. The full implementation is beyond the scope of this description. 

Each individual black-box network is a 2nd order function is terms of *s*. We use MATLAB's Control Systems Toolbox which provides easy functionality for working with transfer functions in Laplace domain. Then, constraints are applied to each network. We must ensure that the total response is passive [3] and reciprocal so that the final response is physically realizable. Then, the TSC algorithm begins optimizing the black-box network to produce the desired input. Two optimizations are run: a quick curve fitting algorithm which attempts to find an optimal point (stage 1), and a longer gradient descent approach (stage 2).

## Research
This code was developed under the [Mine's Undergraduate Research Fellowship](https://www.mines.edu/undergraduate-research/), which kindly provided funding for the project. The final product was presented on April 16th, 2025, at the [Undergraduate Symposium](https://www.mines.edu/undergraduate-research/ugresearchsymposium/).

[Project Details](https://www.mines.edu/undergraduate-research/inverse-design-of-passive-and-active-microwave-circuits/)

## License
All code is provided under the [MIT License](LICENSE)

## Citations
[1] R. E. Collin, Foundations for microwave engineering, Second edition, Reissued edition. New York: IEEE Press, 2001.
[2] K. C. Gupta, R. Garg, and R. Chadha, Computer-aided design of microwave circuits. Dedham, Mass: Artech, 1981.
[3] J. Wyatt, L. Chua, J. Gannett, I. Goknar, and D. Green, “Energy concepts in the state-space theory of nonlinear n-ports: Part I-Passivity,” IEEE Transactions on Circuits and Systems, vol. 28, no. 1, pp. 48–61, Jan. 1981, doi: 10.1109/TCS.1981.1084907.




