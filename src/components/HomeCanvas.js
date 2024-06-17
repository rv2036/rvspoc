import React, { useRef, useEffect } from 'react';
import p5 from 'p5';

const HomeCanvas = () => {
  const canvasRef = useRef(null);

  useEffect(() => {
    const sketch = (p) => {
      const onScreen = (v) => {
        return v.x >= 0 && v.x <= p.width && v.y >= 0 && v.y <= p.height;
      }

      const getRandomInt = (min, max) => {
        min = Math.ceil(min);
        max = Math.floor(max);
        return Math.floor(Math.random() * (max - min + 1)) + min;
      }

      let rate = 60;

      const eraseOutdatedPoint = (index) => {
        const ttp = particlesDrawed[index].shift();
        p.erase();
        p.circle(ttp.x, ttp.y, 0.3);
        p.noErase();
      }

      const num = 100;
      let particles = [];
      let particlesSpeed = [];
      let particlesLength = [];
      let particlesLengthCur = [];
      let particlesDrawed = [];
      let particlesErasing = [];

      const bgColorDark = p.color(10, 10, 10, 30);
      const bgColorLight = p.color(230, 230, 230, 10);
      const fgColorDark = p.color(61, 174, 233, 80);
      const fgColorLight = p.color(35, 32, 36, 60);
      const htmlEle = document.querySelector('html');
      let previousTheme, currentTheme;
      let fgColor = fgColorDark;

      p.setup = () => {
        /*
        const coverEle = document.querySelector('div#cover');
        const coverEleHeight = getComputedStyle(coverEle).height;
        const coverEleWidth = getComputedStyle(coverEle).width;
        p.createCanvas(Math.max(p.windowWidth, coverEleWidth), Math.max(p.windowHeight, coverEleHeight));
        */
        // TODO
        p.createCanvas(p.windowWidth, p.windowHeight);
        for(let i = 0; i < num; i ++) {
          particles.push(p.createVector(p.random(p.width*0.9), p.random(p.height)));
          particlesSpeed.push(Math.random()+0.5);
          particlesLengthCur.push(0);
          particlesLength.push(getRandomInt(Math.min(80, p.width/9), p.width*2));
          particlesDrawed[i] = [];
          particlesErasing[i] = false;
        }
        p.stroke(fgColor);
        p.strokeWeight(1);
        p.clear();
        p.background(bgColorDark);
      };

      p.draw = () => {
        if (window.scrollY <= window.innerHeight) {
          for(let i = 0; i < num; i ++) {
            if (particlesErasing[i]) {
              eraseOutdatedPoint(i);
            }
          }
          currentTheme = htmlEle.getAttribute('data-theme');
          if (currentTheme == 'dark') {
            p.background(bgColorDark);
            fgColor = fgColorDark;
          } else {
            p.background(bgColorLight);
            fgColor = fgColorLight;
          }
          if (currentTheme != previousTheme) {
            p.clear();
            p.stroke(fgColor);
            previousTheme = currentTheme;
          }
          if (p.mouseIsPressed === true) {
            rate = 120;
          } else {
            rate = 60;
          }
          p.frameRate(rate);
          for(let i = 0; i < num; i ++) {
            let tp = particles[i];
            p.point(tp.x, tp.y);
            particlesDrawed[i].push({x: tp.x, y: tp.y});
            if (particlesLength[i] > particlesLengthCur[i]) {
              particlesLengthCur[i]++;
            } else {
              particlesErasing[i] = true;
            }
            tp.x += 0.4 * particlesSpeed[i];
            tp.y -= 0.1 * particlesSpeed[i];
            if(!onScreen(tp)) {
              tp.x = p.random(p.width/2);
              tp.y = p.random(p.height);
            }
          }
        }
      };

      p.windowResized = () => {
        p.resizeCanvas(p.windowWidth, p.windowHeight);
      };
    };

    const myP5 = new p5(sketch, canvasRef.current);

    return () => {
      myP5.remove();
    };
  }, []);

  return <div ref={canvasRef} style={{ position: 'absolute', top: 0, left: 0, zIndex: -1 }} />;
};

export default HomeCanvas;
