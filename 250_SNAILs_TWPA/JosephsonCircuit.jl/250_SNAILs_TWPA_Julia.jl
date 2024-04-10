using JosephsonCircuits
using Plots
@variables Rleft Rright Cg Lj1 Cj1 Lj2 Cj2
circuit = Tuple{String,String,String,Num}[]

# port on the input side
push!(circuit,("P$(1)_$(0)","1","0",1))
push!(circuit,("R$(1)_$(0)","1","0",Rleft))
Nj=250
j=1
for i = 1:Nj  

    # make the jj cell with modified capacitance to ground
    push!(circuit,("C$(j)_$(0)","$(j)","$(0)",Cg))
    push!(circuit,("Lj$(j)_$(j+1)","$(j)","$(j+1)",Lj1))
    push!(circuit,("C$(j)_$(j+1)","$(j)","$(j+1)",Cj1))
    push!(circuit,("Lj$(j+1)_$(j+2)","$(j+1)","$(j+2)",Lj1))
    push!(circuit,("C$(j+1)_$(j+2)","$(j+1)","$(j+2)",Cj1))
    push!(circuit,("Lj$(j+2)_$(j+3)","$(j+2)","$(j+3)",Lj1))
    push!(circuit,("C$(j+2)_$(j+3)","$(j+2)","$(j+3)",Cj1))
    push!(circuit,("Lj$(j)_$(j+3)","$(j)","$(j+3)",Lj2)) 
    push!(circuit,("C$(j)_$(j+3)","$(j)","$(j+3)",Cj2))    
    
    # increment the index
    j=j+3

end

push!(circuit,("R$(j)_$(0)","$(j)","$(0)",Rright))
push!(circuit,("P$(j)_$(0)","$(j)","$(0)",2))

circuitdefs = Dict(
    Lj1 => IctoLj(1.47e-6),
    Cj1 => 80.0e-15,
    Lj2 => IctoLj(0.0735e-6),
    Cj2 => 4e-15,
    Cg => 550.0e-15,
    Rleft => 50.0,
    Rright => 50.0,
)


ws=2*pi*(3.5:0.1:10.5)*1e9
wp=(2*pi*6.0*1e9,)
Ip=0.6e-6
sources = [(mode=(1,),port=1,current=Ip)]
Npumpharmonics = (20,)
Nmodulationharmonics = (10,)

@time rpm = hbsolve(ws, wp, sources, Nmodulationharmonics,
    Npumpharmonics, circuit, circuitdefs)

p1=plot(ws/(2*pi*1e9),
    10*log10.(abs2.(rpm.linearized.S(
            outputmode=(0,),
            outputport=2,
            inputmode=(0,),
            inputport=1,
            freqindex=:),
    )),
    ylim=(-40,30),label="S21",
    xlabel="Signal Frequency (GHz)",
    legend=:bottomright,
    title="Scattering Parameters",
    ylabel="dB")

plot!(ws/(2*pi*1e9),
    10*log10.(abs2.(rpm.linearized.S((0,),1,(0,),2,:))),
    label="S12",
    )

plot!(ws/(2*pi*1e9),
    10*log10.(abs2.(rpm.linearized.S((0,),1,(0,),1,:))),
    label="S11",
    )

plot!(ws/(2*pi*1e9),
    10*log10.(abs2.(rpm.linearized.S((0,),2,(0,),2,:))),
    label="S22",
    )
