function xc=Cepstrum_(x,dft_size)
w=HanningWindow_(dft_size);

for n=1:dft_size,
   x(n)=x(n)*w(n);
end
X=fft(x,dft_size);
A=zeros(1,dft_size);

for k=1:dft_size,
   A(k)=log10(abs(X(k)));
end
xc=ifft(A,dft_size);

