# PiCaSO : A Scalable and Fast PIM Overlay

## Paper Abstract 

The dominance of machine learning and the ending
of Moore’s law have renewed interests in Processor in Mem-
ory (PIM) architectures. This interest has produced several
recent proposals to modify an FPGA’s BRAM architecture
to form a next-generation PIM reconfigurable fabric.
PIM architectures can also be realized within today’s FPGAs
as overlays without the need to modify the underlying FPGA
architecture. To date, there has been no study to understand the
comparative advantages of the two approaches. In this work,
we present a study that explores the comparative advantages
between two proposed custom architectures and a PIM overlay
running on a commodity FPGA. We created PiCaSO, a Processor
in/near Memory Scalable and Fast Overlay architecture as a
representative PIM overlay. The results of this study show that
the PiCaSO overlay achieves up to 80% of the peak throughput
of the custom designs with 2.56× shorter latency and 25% – 43%
better BRAM memory utilization efficiency. We then show how
several key features of the PiCaSO overlay can be integrated into
the custom PIM designs to further improve their throughput by
18%, latency by 19.5%, and memory efficiency by 6.2%.

## Publications
- MD Arafat Kabir, Ehsan Kabir, Joshua Hollis, Eli Levy-Mackay, Atiyehsadat Panahi, Jason Bakos, Miaoqing Huang, and David Andrews, "FPGA Processor In Memory Architectures (PIMs): Overlay or Overhaul?" The 33rd International Conference on Field-Programmable Logic and Applications (FPL 2023), pp. 1-7, September 2023. 
[arXiv](https://doi.org/10.48550/arXiv.2308.03914) 
[IEEE](https://doi.org/10.1109/FPL60245.2023.00023)
- MD Arafat Kabir, Joshua Hollis, Atiyehsadat Panahi, Jason Bakos, Miaoqing Huang, and David Andrews, "Making BRAMs Compute: Creating Scalable Computational Memory Fabric Overlays," The 31st IEEE International Symposium On Field-Programmable Custom Computing Machines (FCCM 2023), pp. 1-1, May 2023. 
[IEEE](https://doi.org/10.1109/FCCM57271.2023.00052)
[PDF](http://turing.uark.edu/~makabir/files/shared/pub/fccm-2023-poster.pdf)

## Directory Structure

<dl>
    <dt>lib</dt>
    <dd>Contains the modules needed to implment the PiCaSO (PIM) block. The submodules are: 
        <dl>
            <dt>alu</dt>
                <dd>Contains implementation of the bit-serial ALU and its submodules. </dd>
            <dt>network</dt>
                <dd>Contains implementation of the binary-hopping accumulation network and its submodules.</dd>
            <dt>opmux</dt>
                <dd>Contians implementation of the operand multiplexer and its submodules.</dd>
            <dt>regfile</dt>
                <dd>Contians implementation of the register file.</dd>
        <dl>
    </dd>
    <dt>tb</dt>
    <dd>Contains testbenches and configuration files needed to build Vivado projects for synthesis and implementation.</dd>
    <dt>work</dt>
    <dd>The workspace with a makefile to build and test different configurations of PiCaSO using iverilog and Vivado projects.</dd>
</dl>


## Requirements

To run the makefile commands under the "work" directory following tools are needed,

- iverilog
- Vivado 2022.2 or above (2019.2 might also work)


## Acknowledgements


The development of PiCaSO is supported by National Science Foundation under 
<a href="https://www.nsf.gov/awardsearch/showAward?AWD_ID=1955820&HistoricalAwards" target="_blank">Grant No. 1955820</a>.
<br><br>
<a href="https://www.nsf.gov/awardsearch/showAward?AWD_ID=1955820&HistoricalAwards" target="_blank" style="text-decoration: none;">
    <img src="/asset/NSF_logo.png" alt="NSF Logo" style="width: 100px; height: 100px; margin-right: 10px;">
</a>
