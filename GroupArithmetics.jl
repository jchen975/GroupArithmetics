using LinearAlgebra
using Primes

#################################### D_n #####################################
R(θ) = [cos(θ) -sin(θ); sin(θ) cos(θ)]  # rotations in 2d
F(θ) = [cos(θ) sin(θ); -sin(θ) cos(θ)]  # reflection in 2d about y = tan(θ/2)x

# order of a rotation by θ; a little jank, should be using Rational{Int64} instead
function R_order(θ)
    θ /= pi
    θ %= 2.0
    θ == 0.0 && return 1
    k = Int(1)
    while θ*k % 2.0 != 0.0
        k += 1
    end
    return k
end


################################### U(n) ######################################
U(n::Integer) = [i for i=1:n if gcd(i,n) == 1]

function ϕ(n::Integer)  # Euler Totient Function
    iszero(n) && return "ϕ(0) is not defined"
    ϕ = one(n)
    for (p,k) in factor(abs(n))
        ϕ *= p^(k-1) * (p-1)
    end
    return ϕ
end

function U_gen(n::Integer)  # generators of U(n)
    # U(n) is cyclic iff n = 1,2,4,p^k or 2p^k for some odd prime p and integer k
    pfactor = Dict(factor(n))
    error = "U($n) has no generator."
    if n != 2 && n != 4
        length(pfactor) > 2 && return error
        factors = collect(keys(pfactor))
        if length(factors) == 2 && (!(2 in factors) || pfactor[2] != 1)
            return error
        end
    end
    Un = U(n)
    gen = Int[]
    order = ϕ(n)
    for k in Un
        if length(U_sub(k, n)) == length(Un)
            gen = vcat(gen, k)
        end
    end
    return gen
end

function U_sub(k::Integer, n::Integer)  # subgroup generated by k in U(n)
    order = ϕ(n)
    return sort(unique([k^i % n for i = 0:order-1]))
end

function U_order(k::Integer, n::Integer)  # order of element k in U(n)
    !(k in U(n)) && return "$k is not in U($n)."
    a = one(k)
    order = ϕ(n)  # max order
    for i = 1:order
        a *= k
        a % n == 1 && return i
    end
    return -1
end

################################### Z(n) ######################################
Z_gen(n::Integer) = [i for i = 0:n if gcd(i,n) == 1]  # generators of Z(n)

function Z_sub(k::Integer, n::Integer)  # subgroup generated by k in Z(n)
    if gcd(k,n) == 1
        return "$k is a generator of Z($n), thus, generates the whole group."
    end
    return sort(unique([k*i % n for i = 1:n]))
end


function Z_order(k::Integer, n::Integer)  # order of element k in Z(n)
    a = zero(k)
    for i = 1:n
        a += k
        a % n == 0 && return i
    end
end
