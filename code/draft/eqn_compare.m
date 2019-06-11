%% general: eqn 14 and 28
s=randi([-100 100], 4, 2);
a=randi([-100 100], 4, 2);

t0 = 0; t1 = 0;
for n0 = 1: 4
    for n1 = 1: 4
        for m0 = 1: 2
            for m1 = 1: 2
                for m2 = 1: 2
                    for m3= 1: 2
                        t0 = t0 + s(n0, m0) * a(n0, m0) * s(n0, m2) * a(n0, m2) * s(n1, m1) * a(n1, m1) * s(n1, m3) * a(n1, m3);
                    end
                end
            end
        end
    end
end

for n = 1: 4
    for m0 = 1: 2
        for m1 = 1: 2
            t1 = t1 + s(n, m0) * a(n, m0) * s(n, m1) * a(n, m1);
        end
    end
end
t1 = t1 ^ 2;

d = t0 - t1
%% lower-bound: eqn 44
s=randi([-100 100], 4, 2);
a=randi([-100 100], 4, 2);

t0 = 0; t1 = 0;
for n0 = 1: 4
    for n1 = 1: 4
        t0 = t0 + s(n0) * a(n0) * s(n1) * a(n1);
    end
end

for n = 1: 4
    t1 = t1 + s(n) * a(n);
end
t1 = t1 ^ 2;

d = t0 - t1
