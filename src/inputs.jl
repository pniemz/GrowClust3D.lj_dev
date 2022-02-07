### READ_GCINP reads the input file controlling script parameters
#
#  > Inputs: infile, relative path to file w/ algorithm parameters
#  < Returns: inpD, a dictionary with parsed control parameters
function read_gcinp(inpfile)
    ### open file
    inpD = open(inpfile) do f
        
        # initialize dictionary, line counter
        counter = 0
        inpD = Dict{String,Any}()
        
        # loop over each line
        for line in eachline(f)
            
            # strip whitespace
            sline = strip(line)
            
            # check for empty or comment lines
            if length(sline) < 1
                continue
            elseif sline[1] == '*'
                continue
            else
                counter+=1
            end
            
            # parse data line
            if counter == 1
                inpD["evlist_fmt"] = parse(Int64,sline)
            elseif counter == 2
                inpD["fin_evlist"] = sline
            elseif counter == 3
                inpD["stlist_fmt"] = parse(Int64,sline)
            elseif counter == 4
                inpD["fin_stlist"] = sline
            elseif counter == 5
                data = split(sline)
                inpD["xcordat_fmt"] = parse(Int64,data[1])
                inpD["tdif_fmt"] = parse(Int64,data[2])
            elseif counter == 6
                inpD["fin_xcordat"] = sline
            elseif counter == 7
                inpD["fin_vzmdl"] = sline
            elseif counter == 8
                inpD["fout_pTT"] = sline
            elseif counter == 9
                inpD["fout_sTT"] = sline
            elseif counter == 10
                data = split(sline)
                inpD["vpvs_factor"] = parse(Float64,data[1])
                inpD["rayparam_min"] = parse(Float64,data[2])
            elseif counter == 11
                data = split(sline)
                inpD["tt_dep0"] = parse(Float64,data[1])
                inpD["tt_dep1"] = parse(Float64,data[2])
                inpD["tt_ddep"] = parse(Float64,data[3])
            elseif counter == 12
                data = split(sline)
                inpD["tt_del0"] = parse(Float64,data[1])
                inpD["tt_del1"] = parse(Float64,data[2])
                inpD["tt_ddel"] = parse(Float64,data[3])
            elseif counter == 13
                data = split(sline)
                inpD["rmin"] = parse(Float64,data[1])
                inpD["delmax"] = parse(Float64,data[2])
                inpD["rmsmax"] = parse(Float64,data[3])
            elseif counter == 14
                data = split(sline)
                inpD["rpsavgmin"] = parse(Float64,data[1])
                inpD["rmincut"] = parse(Float64,data[2])
                inpD["ngoodmin"] = parse(Int64,data[3])
                inpD["iponly"] = parse(Int64,data[4])
            elseif counter == 15
                data = split(sline)
                inpD["nboot"] = parse(Int64,data[1])
                inpD["nbranch_min"] = parse(Int64,data[2])
            elseif counter == 16
                inpD["fout_cat"] = sline
            elseif counter == 17
                inpD["fout_clust"] = sline
            elseif counter == 18
                inpD["fout_log"] = sline
            elseif counter == 19
                inpD["fout_boot"] = sline  
            else
                break
            end
                
        end # close loop over lines
        
        # check for too few lines
        if counter <19
            println("Error, fewer than 19 valid input file lines.")
            exit()
        else
            return inpD
        end
    
    end # closes file
    
    # return results
    return inpD
end

### INPUT_CHECK validates input file parameters
#
#  > Inputs: inpD, a dictionary with parsed control parameters
#  < Returns: input_ok, a boolean check
function check_gcinp(inpD)
    
    # inputs assumed ok until proven otherwise
    println("Checking input parameters...")
    input_ok = true
    
    # check min ray parameters plongcutP, plongcutS
    if ((inpD["plongcutP"] < 0) | (inpD["plongcutS"] < 0))
        println("Input error, ray param cutoffs plongcutP, plongcut:")
        println("$plongcutP, $plongcutS")   
        input_ok = false
    end

    # check vp/vs ratio
    if (inpD["vpvs_factor"] < 0.0)
        println("Input error, Vp/Vs vpvs_factor:")
        println("vpvs_factor") 
        input_ok = false
    end

    # check evlist and stlist format
    if !(inpD["evlist_fmt"] in [1,2,3])
        println( "Input error, unknown evlist format: ",
                inpD["evlist_fmt"])
        println("Must be either 1 or 2 or 3")
        println( "Please fix input file: ", inpfile)
        input_ok = false
     end
     if !(inpD["stlist_fmt"] in [1,2])
        println( "Input error, unknown stlist format: ",
                inpD["stlist_fmt"])
        println("Must be either 1 or 2")
        println( "Please fix input file: ", inpfile)
        input_ok = false
     end

    # check tdif format
    if ((inpD["tdif_fmt"] != 12) & (inpD["tdif_fmt"] != 21))
        println( "Input error, unknown tdif sign convention: ",
                inpD["tdif_fmt"])
        println( "   12: event 1 - event 2")
        println( "   21: event 2 - event 1")
        println( "Please fix input file: ", inpfile)
        input_ok = false
     end

    # check travel-time table: dep and del
    if ((inpD["tt_dep0"] < 0.0) | (
         inpD["tt_dep1"] < inpD["tt_dep0"]) | (
         inpD["tt_ddep"] > inpD["tt_dep1"]))
        println( "Input error: travel time depth grid:")
        println( "$tt_dep1, $tt_dep2, $tt_dep3")
        input_ok = false
    end
    if ((inpD["tt_del0"] < 0.0) | (
         inpD["tt_del1"] < inpD["tt_del0"]) | (
         inpD["tt_ddel"] > inpD["tt_del1"]))
        println("Input error, travel time distance grid:")
        println("$tt_del1, $tt_del2, $tt_del3")
        input_ok = false
    end

    # check rmsmax and delmax
    if ((inpD["rmsmax"] <= 0.0) | (inpD["delmax"] <= 0.0) )
        println( "Input error, GrowClust params : rmsmax, delmax")
        println( "rmsmax, delmax")
        input_ok = false
    end

    # check iponly
    if ((inpD["iponly"] < 0) | (inpD["iponly"] > 2))
        println( "Input error, GrowClust params : iponly")
        println( "$iponly" )
        input_ok = false
    end

    # check nboot
    if ((inpD["nboot"] < 0) | (inpD["nboot"] > 10000)) 
         println( "Input error: nboot, maxboot")
         println( "$nboot, $maxboot")
         input_ok = false
    end    

    # return
    return input_ok
    
end

### CHECK_AUXPARAMS validates global parameters
#
#  > Inputs: global run parameters: hshiftmax, vshiftmax, rmedmax,
#       boxwid, nit, irelonorm, vzmodel_type, mapproj
#  < Returns: params_ok, a boolean check
function check_auxparams(hshiftmax, vshiftmax, rmedmax,
    boxwid, nit, irelonorm, vzmodel_type, ttabsrc, mapproj)

# assume params ok unless problem is found
println("Checking auxiliary run parameters")
params_ok = true 

# check hshiftmax, vshiftmax
if ((hshiftmax <= 0.0) | (vshiftmax <= 0.0))  
    println("parameter error: hshiftmax, vshiftmax")
    println(hshiftmax)
    println(vshiftmax)
    params_ok = false
end

# check rmedmax
if (rmedmax < 0.0)  
    println("parameter error: rmedmax")
    println(rmedmax)
    params_ok = false
end 

# check boxwid, nit
if ((boxwid <= 0.0) | (nit >=200))  
    println("parameter error: boxwid, nit")
    println(boxwid, nit)
    params_ok = false
end

# check irelonorm
if ((irelonorm < 1) | (irelonorm > 3))  
    println("parameter error: irelonorm")
    println(irelonorm)
    params_ok = false
end

# check vz_model type
if ((vzmodel_type < 1) | (vzmodel_type > 3))  
    println("parameter error: vzmodel_type")
    println(vzmodel_type)
    params_ok = false
end

# travel time calculation mode
if !(ttabsrc in ["trace"])
    println("parameter error: ttabsrc")
    println(ttabsrc)
    params_ok=false
end


# check map projections
if !(mapproj in ["aeqd", "lcc", "merc", "tmerc"])
    println("parameter error: mapproj (not implemented)")
    println(mapproj)
    params_ok = false
end

# return
return params_ok                                                     


end

### Event Catalog Reader
#
#  > Inputs: name of event file, integer file format
#  < Returns: event dataframe
function read_evlist(evfile,evfmt)

    # define column names
    if evfmt == 1
        cols=["qyr","qmon","qdy","qhr","qmin","qsc",
            "qlat","qlon","qdep","qmag","eh","ez","rms","qid"]
    elseif evfmt == 2
        cols=["qyr","qmon","qdy","qhr","qmin","qsc",
            "qid","qlat","qlon","qdep","qmag"]
    elseif evfmt == 3
        cols=["qid","qyr","qmon","qdy","qhr","qmin","qsc",
            "qlat","qlon","qdep","rms","eh","ez","qmag"]
    end
    #ncols=length(cols)
    
    # read all columns, converting where possible
    df = DataFrame(readdlm(evfile,Float64),cols)
    
    # compute otime 
    df[!,:qsc] = Base.round.(df[!,:qsc],digits=3) # DateTimes have ms precision
    df[!,:qotime] = DateTime.(convert.(Int32,df[!,:qyr]),
        convert.(Int32,df[!,:qmon]),convert.(Int32,df[!,:qdy]),
        convert.(Int32,df[!,:qhr]),convert.(Int32,df[!,:qmin]),
        convert.(Int32,floor.(df[!,:qsc])), convert.(Int32,
            round.(1000.0*(df[!,:qsc].-floor.(df[!,:qsc]))))
        ) 

    # event ids and serial event number
    df[!,:qid] = convert.(Int64,df[!,:qid])
    df[!,:qix] = Vector{Int32}(1:nrow(df))
    
    # reformat for output
    outcols=["qix","qid","qotime","qmag","qlat","qlon","qdep"]
    select!(df,outcols)
    
    # return results
    return df
    
end

### Station List Reader
#
#  > Inputs: name of station file, integer file format
#  < Returns: event dataframe
function read_stlist(stfile,stfmt)

    # define column names
    if stfmt == 1
        cols=["sta", "slat", "slon"]
        dtypes = [String,Float64,Float64]
    elseif stfmt == 2
        cols=["sta", "slat", "slon", "selev"]
        dtypes = [String,Float64,Float64,Float64]
    end
    #ncols=length(cols)
    
    # read all columns
    df = DataFrame(readdlm(stfile,Any),cols)
    for (col, ctype) in zip(cols,dtypes)
        if ctype == String
            df[!,col] = string.(df[!,col]) 
        else
            df[!,col] = convert.(ctype,df[!,col])
        end
    end
    
    # convert elevations to km
    if "selev" in names(df)
        df[!,:selev] ./= 1000.0
    else # set to zero
        df[!,:selev] .= 0.0
    end
    
    # reformat for output, selecting unique rows
    outcols=["sta","slat","slon","selev"]
    select!(df,outcols)
    unique!(df) # removes duplicate rows
    
    # return results
    return df
    
end

### Xcorr Data Reader
#  > Inputs: input parameters, event dataframe, station dataframe
#  < Returns: xcor dataframe
#  note: original function for event / station data in latlon coords
function read_xcordata_lonlat(inpD,qdf,sdf)

    # unpack parameters
    xcfile = inpD["fin_xcordat"]
    xcfmt = inpD["xcordat_fmt"]
    tdiffmt = inpD["tdif_fmt"]
    rmincut = Float32(inpD["rmincut"])
    rpsavgmin = Float32(inpD["rpsavgmin"])
    rmingood = Float32(inpD["rmin"])
    ngoodmin =inpD["ngoodmin"]
    iponly = inpD["iponly"]
    delmax = inpD["delmax"]
    
    # only text file for now
    if xcfmt != 1
        println("XCOR FORMAT NOT IMPLEMENTED:",xcfmt)
        exit()
    end
    
    # read initial data
    cols = ["sta", "tdif", "rxcor", "iphase"]
    tmap = [String, Float64, Float32, Int8]
    xdf = DataFrame(readdlm(xcfile,Any,
        comments=true,comment_char='#', use_mmap=true),cols)
    Threads.@threads for ii in 1:length(cols)
        col = cols[ii]
        if ii == 1
            xdf[!,col] = string.(xdf[!,col])
        elseif ii == 4
            xdf[!,col] = ifelse.(xdf[!,col].=="P",Int8(1),Int8(2))
        else
            xdf[!,col] = convert.(tmap[ii],xdf[!,col])
        end
    end

   # add in event pairs
    xdf[!,:qid1] .= 0
    xdf[!,:qid2] .= 0    
    open(xcfile) do f
        ii = 0
        q1, q2 = 0, 0
        for line in eachline(f)
            if line[1]=='#'
                _, ev1, ev2, _ = split(line)
                q1 = parse(Int64,ev1)
                q2 = parse(Int64,ev2)
            else
                ii+=1
                xdf[ii,:qid1] = q1
                xdf[ii,:qid2] = q2
            end
        end
    end
            
    # Calculate Event Pair statistics
    transform!(groupby(xdf, [:qid1,:qid2]), :rxcor => mean => :gxcor)
    
    # Subset by quality
    if iponly==1
        xdf = xdf[(xdf[!,:rxcor].>=rmincut).&(
                   xdf[!,:gxcor].>=rpsavgmin).&(xdf[!,:iphase].==Int8(1)),:]
    else
        xdf = xdf[(xdf[!,:rxcor].>=rmincut).&(xdf[!,:gxcor].>=rpsavgmin),:]
    end
    
    # Merge Event Location
    xdf = innerjoin(xdf,qdf,on=:qid1=>:qid)
    DataFrames.rename!(xdf,:qlat=>:qlat1,:qlon=>:qlon1,:qix=>:qix1)
    xdf = innerjoin(xdf,qdf,on=:qid2=>:qid)
    DataFrames.rename!(xdf,:qlat=>:qlat2,:qlon=>:qlon2,:qix=>:qix2)
    
    # Centroid of event pair
    xdf[!,:qlat0] = 0.5*(xdf[!,:qlat1].+xdf[!,:qlat2])
    xdf[!,:qlon0] = 0.5*(xdf[!,:qlon1].+xdf[!,:qlon2])
    
    # Merge Station Location
    xdf = innerjoin(xdf,sdf,on=:sta)
    
    # Calculate distances
    xdf[!,:sdist] = map_distance(xdf[!,:qlat0],xdf[!,:qlon0],xdf[!,:slat],xdf[!,:slon])
    
    # Define "good" xcorr
    xdf[!,:igood] .= (xdf[!,:sdist].<=delmax).&(xdf[!,:rxcor].>=rmingood)
    transform!(groupby(xdf, [:qid1,:qid2]), :igood => sum => :ngood)
    
    # Keep only good pairs
    xdf = xdf[xdf[!,:ngood].>=ngoodmin,:]
    
    # redefine tdif to default tt2 - tt1
    if tdiffmt == 12
        xdf[!,:tdif].*=-1.0
    end
    
    # Return       
    select!(xdf,["qix1","qid1","qix2","qid2","sta","tdif","rxcor",
            "slat","slon","sdist","igood","iphase"])
    return xdf
 
    
end

### Xcorr Data Reader
#  > Inputs: input parameters, event dataframe, station dataframe
#  < Returns: xcor dataframe
#  note: original function for event / station data in projected coords
function read_xcordata_proj(inpD,qdf,sdf)

    # unpack parameters
    xcfile = inpD["fin_xcordat"]
    xcfmt = inpD["xcordat_fmt"]
    tdiffmt = inpD["tdif_fmt"]
    rmincut = Float32(inpD["rmincut"])
    rpsavgmin = Float32(inpD["rpsavgmin"])
    rmingood = Float32(inpD["rmin"])
    ngoodmin =inpD["ngoodmin"]
    iponly = inpD["iponly"]
    delmax = inpD["delmax"]
    
    # only text file for now
    if xcfmt != 1
        println("XCOR FORMAT NOT IMPLEMENTED:",xcfmt)
        exit()
    end
    
    # read initial data
    cols = ["sta", "tdif", "rxcor", "iphase"]
    tmap = [String, Float64, Float32, Int8]
    xdf = DataFrame(readdlm(xcfile,Any,
        comments=true,comment_char='#', use_mmap=true),cols)
    Threads.@threads for ii in 1:length(cols)
        col = cols[ii]
        if ii == 1
            xdf[!,col] = string.(xdf[!,col])
        elseif ii == 4
            xdf[!,col] = ifelse.(xdf[!,col].=="P",Int8(1),Int8(2))
        else
            xdf[!,col] = convert.(tmap[ii],xdf[!,col])
        end
    end

   # add in event pairs
    xdf[!,:qid1] .= 0
    xdf[!,:qid2] .= 0    
    open(xcfile) do f
        ii = 0
        q1, q2 = 0, 0
        for line in eachline(f)
            if line[1]=='#'
                _, ev1, ev2, _ = split(line)
                q1 = parse(Int64,ev1)
                q2 = parse(Int64,ev2)
            else
                ii+=1
                xdf[ii,:qid1] = q1
                xdf[ii,:qid2] = q2
            end
        end
    end
            
    # Calculate Event Pair statistics
    transform!(groupby(xdf, [:qid1,:qid2]), :rxcor => mean => :gxcor)
    
    # Subset by quality
    if iponly==1
        xdf = xdf[(xdf[!,:rxcor].>=rmincut).&(
                   xdf[!,:gxcor].>=rpsavgmin).&(xdf[!,:iphase].==Int8(1)),:]
    else
        xdf = xdf[(xdf[!,:rxcor].>=rmincut).&(xdf[!,:gxcor].>=rpsavgmin),:]
    end
    
    # Merge Event Location
    xdf = innerjoin(xdf,qdf,on=:qid1=>:qid)
    DataFrames.rename!(xdf,:qX4=>:qX1,:qY4=>:qY1,:qix=>:qix1)
    xdf = innerjoin(xdf,qdf,on=:qid2=>:qid)
    DataFrames.rename!(xdf,:qX4=>:qX2,:qY4=>:qY2,:qix=>:qix2)
    
    # Centroid of event pair
    xdf[!,:qX4] = 0.5*(xdf[!,:qX1].+xdf[!,:qX2])
    xdf[!,:qY4] = 0.5*(xdf[!,:qY1].+xdf[!,:qY2])
    
    # Merge Station Location
    xdf = innerjoin(xdf,sdf,on=:sta)
    
    # Calculate distances
    #xdf[!,:sdist] = sqrt.((xdf.qX4.-xdf.sX4).^2 .+ (xdf.qY4.-xdf.sY4).^2)
    xdf[!,:sdist] = xydist(xdf.qX4, xdf.qY4, xdf.sX4, xdf.sY4)
    
    # Define "good" xcorr
    xdf[!,:igood] .= (xdf[!,:sdist].<=delmax).&(xdf[!,:rxcor].>=rmingood)
    transform!(groupby(xdf, [:qid1,:qid2]), :igood => sum => :ngood)
    
    # Keep only good pairs
    xdf = xdf[xdf[!,:ngood].>=ngoodmin,:]
    
    # redefine tdif to default tt2 - tt1
    if tdiffmt == 12
        xdf[!,:tdif].*=-1.0
    end
    
    # Return       
    select!(xdf,["qix1","qid1","qix2","qid2","sta","tdif","rxcor",
            "sX4","sY4","sdist","igood","iphase"])
    return xdf
 
    
end