clc;clear;clear all;

[FileName,PathName] = uigetfile('*.*','Ortofoto Seçimi');
secilenortofoto=fullfile(path,file);

[FileName,PathName] = uigetfile('*.*','DEM Seçimi');
secilenDEM=fullfile(path,file);

resim=imread(secilenortofoto);
[DEM,DEMR]=geotiffread(secilenDEM);

imshow(resim);
hold on;

i=1;sonNokta=0;
X=[];
Y=[];
zoomKontrol=0;
zoomDurdur=0;
zoomSay=1;

while i>0
    %Kullanýcýdan Veri Alma Ýþlemi
    if sonNokta==0
    [Zx,Zy,button]=myginput(1,'crosshair');
    else
     [Zx,Zy,button]=myginput(1,'circle');   
Zx=fix(Zx);Zy=fix(Zy);


%Çizim Ýþlemleri Ýçin Nokta Kaydetme

if button==1 %Mouse Tik
    if sonNokta=1
        mesafeX=abs(Zx-X(1,1));
        mesafeY=abs(Zy-Y(1,1));
    end
   if sonNokta==1 && mesafeX<200 && mesafeY<200 && i>4
            X(i,1)=X(1,1);
            Y(i,1)=Y(1,1);
            i=-1;
            fill(X,Y,'r','FaceAlpha','0.3','LineStyle','none');
    else X(i,1)=Zx; 
         Y(i,1)=Zy;
   end
    
   %Noktayý Çiz Ýþlemi
   plot(X,Y,'--gs',...
       'LineWidth',2,....
   'MarkerSize',10,....
   'MarkerEdgeColor','b',...
   'MarkerFaceColor',[0.5 0.5 0.5]);

i=i+1
end

%Hatalý Nokta Silme Ýþlemi

if button==127  %Delete tuþu 
    xBosmu=isempty(X);
    yBosmu=isempty(Y);
    if xBosmu(1,1)==0 && yBosmu(1,1)==0
    
    X(i-1,:)=[];
    Y(i-1,:)=[];
    i=i-1;
    clf('reset'); %Resmi tekrardan resetleme silme iþlemi için..
    imshow(resim);
    hold on
    plot(X,Y,'--gs','LineWidth',2,'MarkerSize',10,'MarkerEdgeColor','b','MarkerFaceColor',[0.5 0.5 0.5]);
    
    end  
end
    
    


%Yakýnlaþma Ýþlemi

if button==43 %Shift+4 Yani + 
    if zoomKontrol==0
    sol=Zx-3000;
    sag=Zx+3000;
    ust=Zy-3000;
    alt=Zy+3000;
    zoomKontrol=1;
    elseif zoomDurdur=0
        sol=sol+500;
        sag=sag-500;
        ust=ust+500;
        alt=alt-500;
   
    xlim([sol sag]);ylim([ust alt]);
    zoomSay=zoomSay+1;
    %Zoom Kontrol Ýþlemi

    xKontrol=abs(sol-sag);
    yKontrol=abs(ust-alt);

if xKontrol<1001 && yKontrol<1001 
    zoomDurdur=1;
end
    end

%Uzaklaþma Ýþlemi
if button==45 % - Tuþu
   zoomDurdur=0;
    if  zoomSay>0 && zoomSay<3
        sol=1;
        sag=DEMR.RasterSize(1,2); %Bu kýsýmda DEMR dosyamýzý kontrol edicez.
        ust=1;
        alt=DEMR.RasterSize(1,2); %Bu kýsýmda DEMR dosyamýzý kontrol edicez.
    
        xlim([sol sag]);
        ylim([ust alt]);
        zoomSay=0;
        zoomKontrol=0;  
        
    elseif  zoomSay>=3
          sol=sol-500;
          sag=sag+00;
          ust=ust-500;
          alt=alt+500;
          zoomSay=zoomSay-1;
        
          xlim([sol sag]);
          ylim([ust alt]);
        
        
        

%Son Yakalama Fonksiyonu Aç/Kapat
if button==115 && sonNokta==0 %S Tuþu
    sonNokta=1;
    msgbox('Son Nokta Yakalama Açýk')
elseif button==115 && sonNokta==1
    sonNokta=0;
     msgbox('Son Nokta Yakalama Kapalý')
end
plot(X,Y,'--gs','LineWidth',2,'MarkerSize',10,'MarkerEdgeColor','b','MarkerFaceColor',[0.5 0.5 0.5]);

%Programdan Çýk Ýþlemi
if button==27 %ESC Tuþu
    i=-1;
    end
end

%Hacim Hesap Ýþlemleri

Koord(:,:,1)=zeros(DEMR.RasterSize(1,1),DEMR.RasterSize(1,2)); %DEM Verisinden alýnacak.
Koord(:,:,2)=zeros(DEMR.RasterSize(1,1),DEMR.RasterSize(1,2)); %DEM Verisinden alýnacak.

for i=1:DEMR.RasterSize(1,1);
    waitbar(i/DEMR.RasterSize(1,1));
    Koord(i,:,2)=i;
end

for j=1:DEMR.RasterSize(1,1);
    waitbar(j/DEMR.RasterSize(1,1));
    Koord(:,j,1)=j;
end



[in on]=inpolygon(Koord(:,:,1),Koord(:,:,2),X,Y);
aa=1;
for i=1:DEMR.RasterSize(1,1);
    for j=1:DEMR.RasterSize(1,2);
        if in(i,j)==1
            Yson(aa,1)=i;
            Xson(aa,1)=j;
            
            DEMVALUE(aa,1)=DEM(Yson(aa,1),Xson(aa,1));
            aa=aa+1;
        end
    end
end

enAltKot=min(DEMVALUE);

for i=1:length(DEMVALUE);
    YukseklikFarklari(i,1)=DEMVALUE(i,1)-enAltKot; %Metre Cinsinden
    Hacim(i,1)=DEMR.CellExtentInWorldX(1,1)^2*YukseklikFarklari(i,1); %DEMR.CellExtentInWorldX DEM dosyasýndan alýndý.
end

ToplamHacim=sum(Hacim); 

