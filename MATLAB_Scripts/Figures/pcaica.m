function [ic,U,pc,V,kurt]=pcaica(data,num_pc,alg)
% ICA with PCA pre-processing and kurtosis ranking
% PCAICA is applicable to large-scale gene expression data
% which can also have missing data. 
% See also: Matthias Scholz et. al, Bioinformatics 20(15):2447-2454. 2004
%
%          ic=pcaica(data)
% [ic,U,pc,V]=pcaica(data)
% [ic,U,pc,V]=pcaica(data,k)
% [ic,U,pc,V]=pcaica(data,k,alg)
%
%
% data - data set, in which each row is a variable (gene) and 
%        each column is an observation (sample)
% k    - number of used principal components in PCA pre-processing  
%        default: k with max sum over squared first two neg kurtosis values  
%        PCA algorithm:  PPCA -- probabilistic PCA (Roweis 1997), code
%        written by Jakob Verbeek: http://lear.inrialpes.fr/~verbeek/software
% ic   - independent components (sorted by kurtosis)
% pc   - principal components (sorted by variance)
% U    - transformation matrix: contains the weights (loadings) of ICA.
%        ICA-transformation: ic = U*data (data must have zero mean);
%        The first (row-wise) vector U(1,:) tells us how strong each 
%        variable (gene) contributes to the first independent component.
%        (large absolute value => large gene contribution) 
%        To get the index (idx) of the n=10 most important variables 
%        and their corresponding contributions/loadings/weights (w) 
%        to the second independent component (i=2) use:
%         i=2; [s,idx]=sort(abs(U(i,:)));idx=idx(end:-1:1);w=U(i,idx);
%         n=10;fprintf(1,'%+.3f \t %5i\n',[w(1:n);idx(1:n)])
% V    - eigenvector matrix: contains the weights (loadings) of PCA.
%        Here, the eigenvectors V(i,:) (the row-vectors) explain the 
%        contribution of each variable on a specific principal component i.
%            
% alg=1 - CubICA4 [Blaschke and Wiskott, 2002] (default)
%         http://itb.biologie.hu-berlin.de/~blaschke/code.html
% alg=2 - FastICA (if installed)
%         http://www.cis.hut.fi/projects/ica/fastica/
% alg=3 - TDSep (if installed)
%         http://ida.first.fhg.de/~ziehe/download.html
%
% Examples:  ICA on automatically detected best k PCs:
%
%                ic=pcaica(data) 
%                plot(ic(1,:),ic(2,:),'.') 
%
%            ICA on 5 PCs:
%
%                [ic,U,pc,V]=pcaica(data,5) 
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

max_pc=10;

if nargin==1             % default settings
  series=true(1);
  alg=1;
end
if nargin==2  
  series=false(1);
  alg=1;
end
if nargin==3  
  series=false(1);
end



% PCA

    if series
      [fs_pca,evecs,data_mean,p] = ppca(data,max_pc);
      idx=2:max_pc;
    else
      [fs_pca,evecs,data_mean,p] = ppca(data,num_pc);
      idx=num_pc;
    end

    
  kurt=zeros(1,max_pc);
  Wcell=cell(1,max_pc);
  ICcell=cell(1,max_pc);
for i=idx(1):idx(end)

  % ICA

  if alg==1, [W,fs_ica]=cubica4(fs_pca(1:i,:)); end 
  if alg==2, [fs_ica,A,W]=fastica(fs_pca(1:i,:),'numOfIC',num_pc,...
                                 'displayMode','off'); end
  if alg==3, [C,D]=tdsep2(fs_pca(1:i,:),[0:3]); 
              W=inv(C);fs_ica=W*fs_pca(1:i,:);  end
 
  if alg>3, error(['Please specify ''alg'' with ''1'', ''2'' or ''3''']),end

  % sorting ICA components by kurtosis
     [kurtosis_values,kurtosis_idx]=sort(get_kurtosis(fs_ica));
     fs_ica=fs_ica(kurtosis_idx,:);
     W=W(kurtosis_idx,:);

     kneg=kurtosis_values(kurtosis_values<0).^2;
     if isempty(kneg),   kurt(i)=0;              end
     if length(kneg)==1, kurt(i)=kneg;           end
     if length(kneg)>1,  kurt(i)=sum(kneg(1:2)); end

     Wcell{i}=W;
     ICcell{i}=fs_ica;
end



% weights (loadings or influences)

    if length(idx)>1
      [m,ibest]=max(kurt);
      fprintf(1,'\nThis result is achieved with k=%i principal components.\n',ibest)
      fprintf(1,'However, similar choices of k might also give good results.\n')
      fprintf(1,'Use: [ic,U,pc,V]=pcaica(data,k)\n\n')
    else
      ibest=idx;
    end

    V=evecs(1:ibest,:);
    U=Wcell{ibest}*V;

    pc=fs_pca(1:ibest,:);
    ic=ICcell{ibest};


    % fs_pca := evecs*remmean(data) % remmean: remove mean
    % fs_ica := W*fs_pca
    % fs_ica := W*evecs*remmean(data)
    %
    % U=W*evecs
    % fs_ica := U*remmean(data)
    % loadings given row-wise: U(n,:)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fs,W,data_mean,p]=ppca(data,k)
% PCA applied to incomplete data
%
% probabilistic PCA (PPCA) [Verbeek 2002]
% based on sensible principal components analysis [S. Roweis 1997]
%
% pc = ppca(data)
% [pc,W,data_mean,xr] = ppca(data,k)
%
%  data - inclomplete data set, d x n - matrix
%          rows:    d variables (genes or metabolites)
%          columns: n samples
%
%  k  - number of principal components (default k=2)
%  pc - principal component scores  (fs:feature space)
%       plot(pc(1,:),pc(2,:),'.')
%  W  - loadings (weights)
%  xr - reconstructed complete data matrix (for k components)
%
%  pc=W*data
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==1
  k=2
end
 

  [C,ss,M,X,Ye]=ppca_mv(data',k,0,0);
  p=Ye';
  W=C';
  data_mean=M';
  fs=X';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [C, ss, M, X,Ye] = ppca_mv(Ye,d,dia,plo);
%
% implements probabilistic PCA for data with missing values, 
% using a factorizing distrib. over hidden states and hidden observations.
%
%  - The entries in Ye that equal NaN are assumed to be missing. - 
%
% [C, ss, M, X, Ye ] = ppca_mv(Y,d,dia,plo);
%
% Y   (N by D)  N data vectors
% d   (scalar)  dimension of latent space
% dia (binary)  if 1: printf objective each step
% plo (binary)  if 1: plot first PCA direction each step. 
%               if 2: plot eigenimages
%
% ss  (scalar)  isotropic variance outside subspace
% C   (D by d)  C*C' +I*ss is covariance model, C has scaled principal directions as cols.
% M   (D by 1)  data mean
% X   (N by d)  expected states
% Ye  (N by D)  expected complete observations (interesting if some data is missing)
%
% J.J. Verbeek, 2002. http://www.science.uva.nl/~jverbeek
%

% threshold = 1e-3;     % minimal relative change in objective funciton to continue
threshold = 1e-6;  % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

if plo; set(gcf,'Double','on'); end

[N,D] = size(Ye);
    
Obs   = ~isnan(Ye);
hidden = find(~Obs);
missing = length(hidden);

% compute data mean and center data
if missing
  for i=1:D;  M(i) = mean(Ye(find(Obs(:,i)),i)); end;
else
    M = mean(Ye);
end
Ye = Ye - repmat(M,N,1);

if missing;   Ye(hidden)=0;end

r     = randperm(N); 
C     = Ye(r(1:d),:)';     % =======     Initialization    ======
C     = randn(size(C));
CtC   = C'*C;
X     = Ye * C * inv(CtC);
recon = X*C'; recon(hidden) = 0;
ss    = sum(sum((recon-Ye).^2)) / ( (N*D)-missing);

count = 1; 
old   = Inf;


while count          %  ============ EM iterations  ==========
    
    if plo; plot_it(Ye,C,ss,plo);    end
   
    Sx = inv( eye(d) + CtC/ss );    % ====== E-step, (co)variances   =====
    ss_old = ss;
    if missing; proj = X*C'; Ye(hidden) = proj(hidden); end  
    X = Ye*C*Sx/ss;          % ==== E step: expected values  ==== 
    
    SumXtX = X'*X;                              % ======= M-step =====
    C      = (Ye'*X)  / (SumXtX + N*Sx );    
    CtC    = C'*C;
    ss     = ( sum(sum( (C*X'-Ye').^2 )) + N*sum(sum(CtC.*Sx)) + missing*ss_old ) /(N*D); 
    
    objective = N*(D*log(ss) +trace(Sx)-log(det(Sx)) ) +trace(SumXtX) -missing*log(ss_old);           
    rel_ch    = abs( 1 - objective / old );
    old       = objective;
    
    count = count + 1;
    if ( rel_ch < threshold) & (count > 5); count = 0;end
    if dia; fprintf('Objective: M %s    relative change: %s \n',objective, rel_ch ); end
    
end             %  ============ EM iterations  ==========


C = orth(C);
[vecs,vals] = eig(cov(Ye*C));
[vals,ord] = sort(diag(vals));
ord = flipud(ord);
vecs = vecs(:,ord);

C = C*vecs;
X = Ye*C;
 
% add data mean to expected complete data
Ye = Ye + repmat(M,N,1);


% ====  END === 




function plot_it(Y,C,ss,plo); 
clf;
    if plo==1
        plot(Y(:,1),Y(:,2),'.');
        hold on; 
        h=plot(C(1,1)*[-1 1]*(1+sqrt(ss)), (1+sqrt(ss))*C(2,1)*[-1 1],'r');
        h2=plot(0,0,'ro');
        set(h,'LineWi',4);
        set(h2,'MarkerS',10);set(h2,'MarkerF',[1,0,0]);
        axis equal;
    elseif plo==2
        len = 28;nc=1;
        colormap([0:255]'*ones(1,3)/255);
        d = size(C,2);
        m = ceil(sqrt(d)); n = ceil(d/m);
        for i=1:d; 
            subplot(m,n,i); 
            im = reshape(C(:,i),len,size(Y,2)/len,nc);
            im = (im - min(C(:,i)))/(max(C(:,i))-min(C(:,i))); 
            imagesc(im);axis off;
        end; 
    end
    drawnow;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [R,y]=cubica4(x)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CubICA (IMPROVED CUMULANT BASED ICA-ALGORITHM)
%
% This algorithm performes ICA by diagonalization fourth-order cumulants.
%
%  [R,y]=cubica4(x)
%
% - x is and NxP matrix of observations
%     (N: Number of components; P: Number of datapoints(samplepoints)) 
% - R is an NxN matrix such that u=R*x, and u has 
%   (approximately) independent components.
% - y is an NxP matrix of independent components
% 
% This algorithm does exactly (1+round(sqrt(N)) sweeps.
%
% Ref: T. Blaschke and L. Wiskott, "An Improved Cumulant Based
% Method for Independent Component Analysis", Proc. ICANN-2002,
% Madrid, Spain, Aug. 27-30.
%
% questions, remarks, improvements, 
% problems to: t.blaschke@biologie.hu-berlin.de.
%
% Copyright : Tobias Blaschke, t.blaschke@biologie.hu-berlin.de.
%
% 2002-02-22
%
% Last change:2003-05-19  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  [N,P]=size(x);

  Q=eye(N);
  Q_ij=eye(N);
  resolution=0.001;
  
  % centering and whitening 
  
  % fprintf('\ncentering and whitening!\n\n');
  
  x=x-mean(x,2)*ones(1,P);
  [V,D]=eig(x*x'/P);
  W=diag(real(diag(D).^(-0.5)))*V';
  y=W*x;
  
  % fprintf('rotating\n');
  
  % start rotating
  
  for t=1:(1+round(sqrt(N))),
    for i=1:N-1,
      for j=i+1:N,
	
	%calculating the new cumulants

	u=y([i j],:);
	
	sq=u.^2;
	
	sq1=sq(1,:);
	sq2=sq(2,:);
	u1=u(1,:)';
	u2=u(2,:)';
	
	C1111=sq1*sq1'/P-3;
	C1112=(sq1.*u1')*u2/P;
	C1122=sq1*sq2'/P-1;
	C1222=(sq2.*u2')*u1/P;
	C2222=sq2*sq2'/P-3;
	
	% coefficients
	
	c_44=(1/16)*(7*(C1111*C1111+C2222*C2222)-16*(C1112*C1112+C1222*C1222)-12*(C1111*C1122+C1122*C2222)-36*C1122*C1122-32*C1112*C1222-2*C1111*C2222);
	
	s_44=(1/32)*(56*(C1111*C1112-C1222*C2222)+48*(C1112*C1122-C1122*C1222)+8*(C1111*C1222-C1112*C2222));
	
	c_48=(1/64)*(1*(C1111*C1111+C2222*C2222)-16*(C1112*C1112+C1222*C1222)-12*(C1111*C1122+C1122*C2222)+36*C1122*C1122+32*C1112*C1222+2*C1111*C2222);
	
	s_48=(1/64)*(8*(C1111*C1112-C1222*C2222)-48*(C1112*C1122-C1122*C1222)-8*(C1111*C1222-C1112*C2222));
	
	phi_4=-atan2(s_44,c_44);
	phi_8=-atan2(s_48,c_48);
	
	B_4=sqrt(c_44^2+s_44^2);
	B_8=sqrt(c_48^2+s_48^2);
	
	%calculating the angle
	
	approx=-phi_4/4-(pi/2)*fix(-phi_4/pi);
	
	intervall=(approx-pi/8):resolution:(approx+pi/8);
	
	psi_4=B_8*cos(8*intervall+phi_8)+B_4*cos(4*intervall+phi_4);
	
	[value,index]=max(psi_4);
	
	phi_max=intervall(index);
	
	% a different way to calculate the angle is via the matlab
        % function fminbnd. The command would look like:
	%fun=[num2str(B_8),'*(-1)*cos(8*x+',num2str(phi_8),')-',num2str(B_4),
	%'*cos(4*x+',num2str(phi_4),')'];
	%phi_max=fminbnd(fun,approx-pi/8,approx+pi/8);

	
	%Givens-rotation-matrix Q_ij

	Q_ij=eye(N);

	c=cos(phi_max);
	s=sin(phi_max);
	
	Q_ij(i,j)=s;
	Q_ij(j,i)=-s;
	Q_ij(i,i)=c;
	Q_ij(j,j)=c;
	
	Q=Q_ij*Q;

	% rotating y
	
	y([i j],:)=[c s;-s c]*u;
	
      end %j
    end %i
  end %t

  R=Q*W;

  return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function k=get_kurtosis(x)
%
% k=kurtosis(x)
% 
% row orientated (kurtosis of rows)
%
% The kurtosis is zero 
% for a normal distribution.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[dim,num]=size(x);


k=zeros(dim,1);
for i=1:dim
  k(i) = sum( (x(i,:)-mean(x(i,:))).^4 ) ...
          / ( (num-1) * std(x(i,:)).^4 )          - 3; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 



