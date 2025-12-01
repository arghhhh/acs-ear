
# this has been extracted from the AMT Toolbox file, midleearfilter.m, in the common directory.
# See https://amtoolbox.org/amt-1.6.0/doc/common/middleearfilter.php
# See https://amtoolbox.org for license information


function middle_ear(fs)


    # % The following humanised middle ear filter is a digital implementation
    # % described by Rasha Ibrahim's thesis from 2012. She based this implementation
    # % on the work described by Pascal et al. (JASA 1998)  */
    # %
    # % There are three resulting (2nd-order) filters. For an fs=100 kHz, the
    # % transfer functions to be obtained are (see Ibrahim, 2012, her Eq. A1, A2, and A3):
    # %
    # %            0.9979 - 1.9408 z^-1 + 0.9429 z^-2
    # % H1(z-1) = ------------------------------------
    # %            1.0000 - 1.9395 z^-1 + 0.9420 z^-2
    # %
    # %            0.9984 - 1.9226 z^-1 + 0.9415 z^-2
    # % H2(z-1) = ------------------------------------
    # %            1.0000 - 1.9244 z^-1 + 0.9379 z^-2
    # %
    # %                  0.0286 + 0.0302 z^-1 + 0.0016 z^-2
    # % H3(z-1) = 0.5 x ------------------------------------
    # %                  1.0000 - 1.6748 z^-1 + 0.7847 z^-2
    # % Note that the 0.5 is not defined in Rasha's thesis, but in the code 
    # % that was included in the AMT toolbox version of zilany2009's model.
    
    fp = 1e3; # % prewarping frequency 1 kHz
    C  = 2*pi*fp/tan(pi*fp/fs);
    
    
    m11=1/(C^2+5.9761e3*C+2.5255e7);
    m12=(-2*(C^2)+2*2.5255e7);
    m13=(C^2-5.9761e3*C+2.5255e7);
    m14=(C^2+5.6665e3*C);
    m15=-2*(C^2);
    m16=(C^2-5.6665e3*C);
    m21=1/(C^2+6.4255e3*C+1.3975e8);
    m22=(-2*(C^2)+2*1.3975e8);
    m23=(C^2-6.4255e3*C+1.3975e8);
    m24=(C^2+5.8934e3*C+1.7926e8); 
    m25=-2*(C^2)+2*1.7926e8;	
    m26=C^2-5.8934e3*C+1.7926e8;
    m31=1/(C^2+2.4891e4*C+1.2700e9);
    m32=(-2*(C^2)+2*1.27e9);
    m33=(C^2-2.4891e4*C+1.27e9);
    m34=(3.1137e3*C+6.9768e8);
    m35=2*6.9768e8;
    m36=(-3.1137e3*C+6.9768e8);
    megainmax=2;
#    a(1,1:3) =     [1   m11*m12 m11*m13];
#    b(1,1:3) = m11*[m14     m15     m16];

#    a(2,1:3) =     [1   m21*m22 m21*m23];
#    b(2,1:3) = m21*[m24     m25     m26]; 

#    a(3,1:3) = [1 m31*m32 m31*m33];
#    b(3,1:3) = m31*[m34 m35 m36]/megainmax;    

        f1 = Processors.IIR( m11*[m14     , m15   ,  m16]   , [1, m11*m12, m11*m13] )
        f2 = Processors.IIR( m21*[m24     , m25   ,  m26]   , [1, m21*m22, m21*m23] )
        f3 = Processors.IIR( m31*[m34 , m35 , m36]/megainmax, [1, m31*m32, m31*m33]  )

    return f1 |> f2 |> f3
end

me = middle_ear(48e3)
freqs = range( 10, 20e3; length=1000)
ys = ProcSeqs.freqzdB( me, freqs, 48e3 )
