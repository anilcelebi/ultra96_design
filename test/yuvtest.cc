#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <iostream>
#include <string>
#include <linux/videodev2.h>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#define WIDTH 640
#define HEIGHT 480
#define BUFSIZE (WIDTH*HEIGHT/2)
#define FRAME_NUM 2

static int xioctl(int fd, int request, void *arg){
    int rc;

    do rc = ioctl(fd, request, arg);
    while (-1 == rc && EINTR == errno);
    return rc;
}

// saturate input into [0, 255]
inline unsigned char sat(float f)
{
    return (unsigned char)( f >= 255 ? 255 : (f < 0 ? 0 : f));
}

static void yuyv_to_rgb(unsigned char *yuyv, unsigned char *rgb)
{
    for (int i = 0; i < WIDTH * HEIGHT * 2; i += 4) {
        *rgb++ = sat(yuyv[i]+1.402f  *(yuyv[i+3]-128));
        *rgb++ = sat(yuyv[i]-0.34414f*(yuyv[i+1]-128)-0.71414f*(yuyv[i+3]-128));
        *rgb++ = sat(yuyv[i]+1.772f  *(yuyv[i+1]-128));
        *rgb++ = sat(yuyv[i+2]+1.402f*(yuyv[i+3]-128));
        *rgb++ = sat(yuyv[i+2]-0.34414f*(yuyv[i+1]-128)-0.71414f*(yuyv[i+3]-128));
        *rgb++ = sat(yuyv[i+2]+1.772f*(yuyv[i+1]-128));
    }
}

int main()
{
    int fd, rc;
    int w = 640, h = 480;
    struct v4l2_format fmt;
    struct v4l2_requestbuffers req;
    struct v4l2_buffer buf;
    enum v4l2_buf_type type;
    void *user_frame[BUFSIZE];
    unsigned char rgb_buf[WIDTH*HEIGHT*3];
    struct timeval tv1, tv2;

    fd = open("/dev/video0", O_RDWR);
    if (fd < 0) {
        fprintf(stderr, "open = %d, errno = %d\n", fd, errno);
        return -1;
    }

    memset(&fmt, 0, sizeof(fmt));
    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    fmt.fmt.pix.width = 640;
    fmt.fmt.pix.height = 480;
    fmt.fmt.pix.pixelformat = V4L2_PIX_FMT_YUYV;
    fmt.fmt.pix.field = V4L2_FIELD_ANY;
    rc = xioctl(fd, VIDIOC_S_FMT, &fmt);
    printf("VIDIOC_S_FMT = %d\n", rc);

    memset(&buf, 0, sizeof(buf));
    memset(&req, 0, sizeof(req));
    req.count = FRAME_NUM;
    req.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    req.memory = V4L2_MEMORY_MMAP;
    rc = xioctl(fd, VIDIOC_REQBUFS, &req);
    printf("VIDIOC_REQBUFS = %d\n", rc);
    buf.memory = V4L2_MEMORY_MMAP;
    buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    for (int i = 0; i < FRAME_NUM; i++) {
        buf.index = i;
        rc = xioctl(fd, VIDIOC_QUERYBUF, &buf);
        printf("VIDIOC_QUERYBUF = %d, i= %d, buf.m.offset = %d, buf.length = %d\n", rc, i, buf.m.offset, buf.length);
        user_frame[i] = mmap(NULL, buf.length, PROT_READ | PROT_WRITE, MAP_SHARED, fd, buf.m.offset);
        printf("user_frame[%d] = %p\n", i, user_frame[i]);
        rc = xioctl(fd, VIDIOC_QBUF, &buf);
        printf("VIDIOC_QBUF = %d\n", rc);
    }
    type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    rc = xioctl(fd, VIDIOC_STREAMON, &type);
    printf("VIDIOC_STREAMON = %d\n", rc);

    cv::Mat frame(h, w, CV_8UC3);
    for (int i = 0; i < 20; i++) {
        fd_set fds;
        struct timeval tv;
        FD_ZERO(&fds);
        FD_SET(fd, &fds);
        tv.tv_sec = 2;
        tv.tv_usec = 0;
        rc = select(fd + 1, &fds, NULL, NULL, &tv);
        printf("select%d = %d\n", i, rc);
        if (FD_ISSET(fd, &fds)) {
            printf("FD_ISSET\n");
            rc = xioctl(fd, VIDIOC_DQBUF, &buf);
            printf("VIDIOC_DQBUF = %d, buf.index = %d\n", rc, buf.index);
            if (buf.index < FRAME_NUM) {
                printf("calling yuyv_to_rgb\n");
                gettimeofday(&tv1, NULL);
                yuyv_to_rgb((unsigned char *)user_frame[buf.index], rgb_buf);
                gettimeofday(&tv2, NULL);
                printf("returned from yuyv_to_rgb, elapsed time = %f sec\n", (tv2.tv_sec - tv1.tv_sec) + (tv2.tv_usec - tv1.tv_usec) / 1000000.0f);
                frame.data = (unsigned char *)rgb_buf;
                std::stringstream ss;
                ss << "./" << i << ".png";
                cv::imwrite(ss.str(), frame);
                rc = xioctl(fd, VIDIOC_QBUF, &buf);
                printf("VIDIOC_QBUF = %d\n", rc);
            }
        } else {
            printf("!FD_ISSET\n");
        }
        printf("%d\n", i);
    }

    rc = xioctl(fd, VIDIOC_STREAMOFF, &type);
    printf("VIDIOC_STREAMOFF = %d\n", rc);
    close(fd);

    return 0;
}
