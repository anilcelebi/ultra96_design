#include "xparameters.h"
#include "xcsi.h"

#include "AXI_VDMA.h"

#include "camctrl.h"
#include "camcfg.h"

#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/i2c-dev.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <sys/mman.h>

#define VDMA_DEVID			XPAR_AXIVDMA_0_DEVICE_ID
#define VDMA_MM2S_IRPT_ID	XPAR_FABRIC_AXI_VDMA_0_MM2S_INTROUT_INTR
#define VDMA_S2MM_IRPT_ID	XPAR_FABRIC_AXI_VDMA_0_S2MM_INTROUT_INTR
#define CAM_I2C_SCLK_RATE	100000

#define MAX_BUF_NUM 5
static unsigned long long phys_buf[MAX_BUF_NUM];
static unsigned long long vir_buf[MAX_BUF_NUM];
static int frame_num;
static size_t frame_size;

using namespace digilent;
static AXI_VDMA g_vdma_driver;

static int (*init_camera[])(e_resolution resolution) = {
	init_ov5640,
	init_imx219
};

static void pipeline_mode_change(AXI_VDMA& vdma_driver, e_sensor sensor, e_resolution resolution)
{
	uint16_t h_res, v_res;
	switch (resolution) {
	case RESOLUTION_1920_1080:
		h_res = 1920;
		v_res = 1080;
		break;
	case RESOLUTION_1280_720:
		h_res = 1280;
		v_res = 720;
		break;
	case RESOLUTION_960_540:
		h_res = 960;
		v_res = 540;
		break;
	case RESOLUTION_640_480:
		h_res = 640;
		v_res = 480;
		break;
	case RESOLUTION_640_360:
		h_res = 640;
		v_res = 360;
		break;
	case RESOLUTION_320_240:
		h_res = 320;
		v_res = 240;
		break;
	case RESOLUTION_320_200:
		h_res = 320;
		v_res = 200;
		break;
	default:
		break;
	}

	//Bring up input pipeline back-to-front
	vdma_driver.resetWrite();
	XCsi ins_csi;
	XCsi_Config *psConf;
	u32 Status;

	psConf = XCsi_LookupConfig(0);
	if (!psConf) {
		throw std::runtime_error(__FILE__ ":" LINE_STRING);
	}

	Status = XCsi_CfgInitialize(&ins_csi, psConf, XPAR_MIPI_CSI2_RX_SUBSYST_0_BASEADDR);
	if (Status != XST_SUCCESS) {
		throw std::runtime_error(__FILE__ ":" LINE_STRING);
	}

	vdma_driver.configureWrite(h_res, v_res);
	vdma_driver.enableWrite();

	Status = XCsi_Activate(&ins_csi, XCSI_ENABLE);
	if (Status != XST_SUCCESS) {
		throw std::runtime_error(__FILE__ ":" LINE_STRING);
	}

	#if 0
	int fd = open("/dev/i2c-1", O_RDWR);
	unsigned char dat;
	int ret;
	ret = ioctl(fd, I2C_SLAVE, 0x75);
	printf("ioctl = 0x%x\n", ret);
	dat = 0x4;
	ret = write(fd, &dat, 1);
	printf("write = %d\n", ret);
	dat = 0x5a;
	ret = read(fd, &dat, 1);
	printf("read = %d\n", ret);
	printf("read configuration = 0x%x\n", dat);
	close(fd);
	#endif

	init_camera[sensor](resolution);
}

int caminit(e_sensor sensor, e_resolution resolution, int fnum, size_t fsize)
{
	unsigned long long phys_addr, vir_addr;
	unsigned int size = 0;
	char attr[1024];

	if (fnum > MAX_BUF_NUM) {
		perror("fnum");
		return -1;
	}
	frame_num = fnum;
	frame_size = fsize;

	int fd = open("/dev/mem", O_RDWR);
	if (fd < 0) {
		perror("open(/dev/mem)");
		return -1;
	}

	if (!mmap((void *)XPAR_MIPI_CSI2_RX_SUBSYST_0_BASEADDR, XPAR_MIPI_CSI2_RX_SUBSYST_0_HIGHADDR - XPAR_MIPI_CSI2_RX_SUBSYST_0_BASEADDR, PROT_READ|PROT_WRITE, MAP_SHARED, fd, XPAR_MIPI_CSI2_RX_SUBSYST_0_BASEADDR)) {
		perror("mmap(XPAR_MIPI_CSI2_RX_SUBSYST_0_BASEADDR");
		return -1;
	}
	printf("XPAR_MIPI_CSI2_RX_SUBSYST_0_BASEADDR = 0x%x\n", XPAR_MIPI_CSI2_RX_SUBSYST_0_BASEADDR);
	if (!mmap((void *)XPAR_AXI_VDMA_0_BASEADDR, XPAR_AXI_VDMA_0_HIGHADDR - XPAR_AXI_VDMA_0_BASEADDR, PROT_READ|PROT_WRITE, MAP_SHARED, fd, XPAR_AXI_VDMA_0_BASEADDR)) {
		perror("mmap(XPAR_AXI_VDMA_0_BASEADDR)");
		return -1;
	}
	printf("XPAR_AXI_VDMA_0_BASEADDR = 0x%x\n", XPAR_AXI_VDMA_0_BASEADDR);
	close(fd);

	fd = open("/sys/class/udmabuf/udmabuf0/size", O_RDONLY);
	if (fd < 0) {
		perror("open(/sys/class/udmabuf/udmabuf0/size)");
		return -1;
	}
	read(fd, attr, 1024);
	sscanf(attr, "%u", &size);
	close(fd);
	printf("size = 0x%x\n", size);
	fd = open("/sys/class/udmabuf/udmabuf0/phys_addr", O_RDONLY);
	if (fd < 0) {
		perror("open(/sys/class/udmabuf/udmabuf0/phys_addr)");
		return -1;
	}
	read(fd, attr, 1024);
	sscanf(attr, "%llx", &phys_addr);
	close(fd);
	printf("phys_addr = 0x%llx\n", phys_addr);

	g_vdma_driver.init(VDMA_DEVID, phys_addr);
	printf("vdma init completed\n");
	pipeline_mode_change(g_vdma_driver, sensor, resolution);
	printf("pipeline_mode_change completed\n");

	fd = open("/dev/udmabuf0", O_RDWR);
	if (fd < 0) {
		perror("open(/dev/udmabuf0");
		return -1;
	}

	vir_addr = (unsigned long long)mmap(NULL, size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	printf("vir_addr = 0x%x\n", vir_addr);
	close(fd);

	fd = open("/sys/class/udmabuf/udmabuf0/sync_size", O_WRONLY);
	sprintf(attr, "%d", fsize);
	write(fd, attr, strlen(attr));
	close(fd);

	fd = open("/sys/class/udmabuf/udmabuf0/sync_direction", O_WRONLY);
	sprintf(attr, "%d", 2);
	write(fd, attr, strlen(attr));
	close(fd);

	for (int i = 0; i < fnum; i++) {
		phys_buf[i] = (unsigned long long)(phys_addr + fsize * i);
		vir_buf[i] = (unsigned long long)(vir_addr + fsize * i);
	}

	return 0;
}

unsigned long long get_frame_buffer(void)
{
	static int hw_fno = 1;
	int sw_fno;
	unsigned long long buf;
	char attr[64];
	int fd;

	hw_fno++;
	if (hw_fno == frame_num) {
		hw_fno = 0;
	}
	g_vdma_driver.setWriteBuffer((uint32_t)phys_buf[hw_fno]);
	g_vdma_driver.enableWrite();

	sw_fno = (hw_fno + frame_num - 1) % frame_num;
	buf = vir_buf[sw_fno];

	fd = open("/sys/class/udmabuf/udmabuf0/sync_offset", O_WRONLY);
	sprintf(attr, "%u", sw_fno * frame_size);
	write(fd, attr, strlen(attr));
	close(fd);

	fd = open("/sys/class/udmabuf/udmabuf0/sync_for_cpu", O_WRONLY);
	sprintf(attr, "%d", 1);
	write(fd, attr, strlen(attr));
	close(fd);

	return buf;
}

unsigned char dummy[1024];

void *__ctype_ptr__ = (void *)dummy;
void *_impure_ptr = (void *)dummy;
