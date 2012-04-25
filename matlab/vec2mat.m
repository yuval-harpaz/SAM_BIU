function matrx=vec2mat(vec,dim2size)
% takes a vector (collumn or row) and multiplies dim2size (size of second dimention) times
% it to make a matrix
matrx=vec;
sz=size(vec);
if sz(1)==1
    if sz(2)==1
        error('is vec a vector?')
    end
    for i=2:dim2size
        matrx(i,:)=vec;
    end
elseif sz(2)==1
    for i=2:dim2size
        matrx(:,i)=vec;
    end
else
    error('vec is not a vector, is it?')
end
end