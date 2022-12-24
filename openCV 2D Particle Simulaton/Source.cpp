#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <iostream>
#include <vector>
#include <cmath>
#include <algorithm>
#include <map>

using namespace std;
using namespace cv;

vector<vector<int>> Points(1);
int N = 0;

float normalise(int vx, int vy) {
	float sq = vx * vx + vy * vy;
	sq = sq / 1.0;
	float final = sqrt(sq);
	return final;
}

void click(int event, int x, int y, int flags, void* userdata) {
	if (event == EVENT_LBUTTONDOWN) {
		vector<int> location = {x,y};
		Points[0] = location;
		N += 1;

	}
}

bool compare(vector<int> a, vector<int> b) {
	return (a[0] < b[0]);
}

int main() {

	int y = 600; // image size
	int x = 300;

	float vx = 0.0; // inital vels
	float vy = 0.0;

	int radius = 20;

	int centerx = x / 2;
	int centery = y - radius -1;
	
	int check = 0;


	//colliders
	srand(time(0));
	int num_coll = rand() % 9 + 2; //between 2-10
	int sqsize = 10;
	vector<vector<int>> colliders;
	for (int i = 0; i < num_coll; i++) {
		int x_col = rand() % (x - sqsize * 2) + sqsize;
		int y_col = rand() % (y - sqsize * 2) + sqsize;
		if (x_col < (centerx - radius * 2) || x_col > (centerx + radius * 2)) {
			if (y_col < (centery - radius * 2) && y_col > radius*2) {
				if (x_col > radius * 2 && x_col < x - radius * 2) {
					colliders.push_back({ x_col,y_col });
				}
			}
		}
	}

	VideoCapture cap(0);
	Mat img2;

	while (true) {

		cap.read(img2);
		flip(img2, img2, 1);
		resize(img2, img2, Size(), 1.5, 1.5);
		img2 = img2(Range(0, 600), Range(0, 300));


		Mat img(y, x, CV_8UC3, Scalar(0, 0, 0));


		Mat img_gray;
		cvtColor(img2, img_gray, COLOR_BGR2GRAY);
		threshold(img_gray, img_gray, 150, 255, THRESH_BINARY);
		vector<vector<Point>> contours;
		vector<Vec4i> hierarchy;
		findContours(img_gray, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
		drawContours(img2, contours, -1, Scalar(0, 255, 0), 2);



		if (centerx < radius) {
			centerx = radius;
			vx *= -1;
		}

		else if (centerx > x - radius) {
			centerx = x - radius;
			vx *= -1;
		}

		else if (centery < radius) {
			centery = radius;
			vy *= -1;
		}

		else if (centery > y - radius) {
			centery = y - radius;
			vy *= -1;
		}

		for (int i = 0; i < colliders.size(); i++) {
			int leftsq = colliders[i][0] - sqsize;
			int rightsq = colliders[i][0] + sqsize;
			int topsq = colliders[i][1] - sqsize;
			int bottomsq = colliders[i][1] + sqsize;

			int leftDist = centerx + radius - leftsq;
			int rightDist = centerx - radius - rightsq;
			int topDist = centery + radius - topsq;
			int bottomDist = centery - radius - bottomsq;
			
			vector<vector<int>> sorting = { {abs(leftDist),'X','L'}, {abs(rightDist), 'X','R'}, {abs(topDist),'Y','T'}, {abs(bottomDist),'Y','B'} };
			vector<int> a;
			a = sorting[0];
			for (int i = 0; i < 4; i++) {
				if (a[0] < sorting[i][0]) {
					a = sorting[i];
				}
			}

			if (leftDist >= 0 && rightDist <= 0 && topDist >= 0 && bottomDist <= 0) {


				if (a[1] == 'X') {
					vx *= -1;
					centerx += vx;
					/*if (a[2] == 'L') {
						centerx = leftsq - radius*1;
					}
					else {
						centerx = rightsq + radius*1;
					}*/
				}
				else if (a[1] == 'Y') {
					vy *= -1;
					centery += vy;
					/*if (a[2] == 'T') {
						centery = topsq - radius*1;
					}
					else {
						centery = bottomsq + radius*1;
					}*/
				}
			}
		}

		for (int i = 0; i < colliders.size(); i++) {
			int x_start = colliders[i][0]-sqsize;
			int y_start = colliders[i][1]-sqsize;
			int x_end = colliders[i][0] + sqsize;
			int y_end = colliders[i][1] + sqsize;
			rectangle(img, Point(x_start, y_start), Point(x_end, y_end), Scalar(255, 255, 255), FILLED, LINE_AA);
		}

		centerx += vx;
		centery += vy;

		circle(img, Point(centerx, centery), radius, Scalar(25, 25, 25), FILLED, LINE_AA);
		circle(img, Point(centerx, centery), radius-0.75, Scalar(50, 50, 50), FILLED, LINE_AA);
		circle(img, Point(centerx, centery), radius-1.5, Scalar(75, 75, 75), FILLED, LINE_AA);
		circle(img, Point(centerx, centery), radius-2.25, Scalar(100, 100, 100), FILLED, LINE_AA);
		circle(img, Point(centerx, centery), radius-3, Scalar(125, 125, 125), FILLED, LINE_AA);
		circle(img, Point(centerx, centery), radius-3.75, Scalar(150, 150, 150), FILLED, LINE_AA);
		circle(img, Point(centerx, centery), radius-4.5, Scalar(175, 175, 175), FILLED, LINE_AA);
		circle(img, Point(centerx, centery), radius-5.25, Scalar(200, 200, 200), FILLED, LINE_AA);
		circle(img, Point(centerx, centery), radius-6, Scalar(225, 225, 225), FILLED, LINE_AA);
		circle(img, Point(centerx, centery), radius-6.75, Scalar(255, 255, 255), FILLED, LINE_AA);
		
		namedWindow("Window");

		setMouseCallback("Window", click);
		

		while(check<N) {
			int x_loc = Points[0][0];
			int y_loc = Points[0][1];
			vx = x_loc - centerx;
			vy = y_loc - centery;
			float div = normalise(vx, vy);
			vx = vx / div * 50;
			vy = vy / div * 50;
			check += 1;
		}

		if (abs(vx) < 0.0000001) {
			vx = 0;
		}
		else {
			vx *= 0.95;
		}
		
		if (abs(vy) < 0.0000001) {
			vy = 0;
		}
		else {
			vy *= 0.95;
		}

		
		

		//imshow("Window", img);
		imshow("Image", img2);
		int key = waitKey(24);
		if (key == 27) {
			break;
		}

		

	}

	
}