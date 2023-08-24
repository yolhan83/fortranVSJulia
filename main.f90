program main
    implicit none
    double precision :: xmin,xmax,ymin,ymax,dx,dy,t1,t2,xc,yc,xd,ts
    double precision,  allocatable :: x(:),y(:),result(:,:)
    integer :: i,j,k,l,xn,yn,maxiter
    xmin = -2.25
    xmax = 0.75
    xn = 450
    ymin = -1.25
    ymax = 1.25
    yn = 375
    maxiter = 200
    allocate(x(xn))
    allocate(y(yn))
    allocate(result(xn,yn))
    dx = (xmax-xmin)/(xn-1)
    do i=1,xn
        x(i) = xmin+dx*(i-1)
    end do
    dy = (ymax-ymin)/(yn-1)
    do j=1,yn
        y(j) = ymin+dy*(j-1)
    end do
    result=0
    ts=0
    do l = 1,1000
        call CPU_TIME(t1)
        do i=1,xn
            do j=1,yn
                xc = x(i)
                yc = y(j)
                do k= 1,maxiter
                    xd = xc
                    xc = xc*xc - yc*yc + x(i) 
                    yc = 2*xd*yc + y(j)
                    if (xc*xc + yc*yc > 4) then
                        result(i,j) = k
                        exit
                    end if
                    if (k .eq. maxiter) then
                        result(i,j) = maxiter
                    end if
                enddo
            end do
        end do

        call CPU_TIME(t2)
        ts = ts + t2-t1
    enddo
    print *, "time : ", (ts/1000)*1000
    open(1,file="result.csv", action="write")
    do i=1,xn
        do j=1,yn
            if (j.ne.yn) then
                write(1,'(F10.5)', advance="no") result(i,j)
                write(1,'(A)',advance="no") ","
            else
                write(1,'(F10.5)') result(i,j)
            endif
        end do
    end do
    close(1)
    deallocate(x)
    deallocate(y)
    deallocate(result)
end program main
