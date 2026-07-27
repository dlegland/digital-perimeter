/**
 * 
 */
package net.image.validate.perimeter;

import java.io.File;
import java.io.IOException;
import java.util.Locale;

import ij.IJ;
import ij.ImageJ;
import ij.ImagePlus;
import ij.measure.Calibration;
import ij.measure.Measurements;
import ij.measure.ResultsTable;
import ij.plugin.filter.ParticleAnalyzer;
import ij.process.*;
import ijt.table.Table;
import ijt.table.process.SummaryStatistics;
import inra.ijpb.measure.IntrinsicVolumes2D;
import net.ijt.geometry.geom2d.curve.Circle2D;
import ijt.table.io.*;

/**
 * Evaluates the accuracy of perimeter measurements on a digital images of a
 * disk with fixed increasing radius.
 * 
 * For each radius, 1000 images are generated, with random position with respect
 * to discretisation grid.
 * 
 * Several features are measured:
 * <ul>
 * <li>the area, as the number of pixels in the binary image</li>
 * <li>the perimeter measured by ImageJ</li>
 * <li>the perimeter measured by MorphoLibJ, using Crofton formula with two
 * directions</li>
 * <li>the perimeter measured by MorphoLibJ, using Crofton formula with four
 * directions</li>
 * </ul>
 * For each feature, the average and the standard deviation of the measurements
 * over all repetitions are returned in a data table saved in a text file within
 * the "tables" directory of the project.
 */
public class ValidatePerimeter_Resolution_Disk
{
    public static final int REPETITIONS = 1000;
        
    
    public static final void fillDisk(ImageProcessor image, Circle2D disk, double value)
    {
        // retrieve image size
        int sizeX = image.getWidth();
        int sizeY = image.getHeight();
        
        // iterate over image pixels
        for (int y = 0; y < sizeY; y++)
        {
            for (int x = 0; x < sizeX; x++)
            {
                if (disk.isInside(x + 0.5, y + 0.5))
                {
                    image.setf(x, y, (float) value);
                }
            }
        }
    }
    
    public static final void main(String... args) throws IOException
    {
        System.out.println("run validation of perimeter on disk with various radius");
        
        @SuppressWarnings("unused")
        ImageJ imagejInstance = IJ.getInstance();
        
        double radiusMin = 1.0;
        double radiusMax = 70.0;
        double radiusStep = 0.05;
        
        int nRadius = (int) Math.floor((radiusMax - radiusMin) / radiusStep);
        
        // create summary results tables
        Table resGlobal = Table.create(nRadius, 9);
        Table errorGlobal = Table.create(nRadius, 17);
        String[] colNames = new String[] {"Radius", "Area", "AreaStd", "ImageJ", "ImageJStd", "Crofton2", "Crofton2Std", "Crofton4", "Crofton4Std" };
        resGlobal.setColumnNames(colNames);
        String[] colNames2 = new String[] {
                "Radius", 
                "Area", "AreaStd", "AreaMin", "AreaMax", 
                "ImageJ", "ImageJStd", "ImageJMin", "ImageJMax", 
                "Crofton2", "Crofton2Std", "Crofton2Min", "Crofton2Max", 
                "Crofton4", "Crofton4Std", "Crofton4Min", "Crofton4Max"};
        errorGlobal.setColumnNames(colNames2);
        
        
        for (int iRadius = 0; iRadius < nRadius; iRadius++)
        {
            double radius = iRadius * radiusStep + 1.0;
            System.out.println(String.format(Locale.ENGLISH, "process radius %d/%d = %6.2f", iRadius, nRadius, radius));
            
            // theoretical values
            double areaTh = Math.PI * radius * radius;
            double perimTh = 2.0 * Math.PI * radius;

            int sizeX = (int) Math.ceil(2*radius) + 10;
            int sizeY = (int) Math.ceil(2*radius) + 10;

            Table tableRepets = Table.create(REPETITIONS, 4);
            Table errorRepets = Table.create(REPETITIONS, 4);
            tableRepets.setColumnNames(new String[] {"Area", "Perimeter_ImageJ", "Perimeter_Crofton2", "Perimeter_Crofton4"});
            errorRepets.setColumnNames(new String[] {"Area", "Perimeter_ImageJ", "Perimeter_Crofton2", "Perimeter_Crofton4"});
            
            for (int iRepet = 0; iRepet < REPETITIONS; iRepet++)
            {
                // disk with random position around image center
                double centerX = sizeX / 2 + Math.random();
                double centerY = sizeY / 2 + Math.random();
                Circle2D disk = new Circle2D(centerX, centerY, radius);

                // generate binary image of disk
                ImageProcessor image = new ByteProcessor(sizeX, sizeY);
                fillDisk(image, disk, 255);

                // setup ImagEJ threshold
                ImagePlus imagePlus = new ImagePlus("Disk", image);
                IJ.setAutoThreshold(imagePlus, "Otsu dark");

                // compute perimeter using several methods
                ResultsTable resTable = new ResultsTable();
                int measurements = Measurements.AREA | Measurements.PERIMETER; 
                ParticleAnalyzer analyzer = new ParticleAnalyzer(0, measurements, resTable, 0.0, Double.POSITIVE_INFINITY);
                analyzer.analyze(imagePlus);

                double area = resTable.getValue("Area", 0);
                double perimIJ = resTable.getValue("Perim.", 0);
                double perimCrofton2 = IntrinsicVolumes2D.perimeter(image, new Calibration(), 2);
                double perimCrofton4 = IntrinsicVolumes2D.perimeter(image, new Calibration(), 4);

//                System.out.println("Area = " + area + "  perimeter_IJ = " + perimIJ + "  perimeter_Crofton2 = " + perimCrofton2 + "  perimeter_Crofton4 = " + perimCrofton4);

                tableRepets.setValue(iRepet, "Area", area);
                tableRepets.setValue(iRepet, "Perimeter_ImageJ", perimIJ);
                tableRepets.setValue(iRepet, "Perimeter_Crofton2", perimCrofton2);
                tableRepets.setValue(iRepet, "Perimeter_Crofton4", perimCrofton4);
                
                // also populate table of relative errors
                errorRepets.setValue(iRepet, "Area", 100 * (area - areaTh) / areaTh);
                errorRepets.setValue(iRepet, "Perimeter_ImageJ", 100 * (perimIJ - perimTh) / perimTh);
                errorRepets.setValue(iRepet, "Perimeter_Crofton2", 100 * (perimCrofton2 - perimTh) / perimTh);
                errorRepets.setValue(iRepet, "Perimeter_Crofton4", 100 * (perimCrofton4 - perimTh) / perimTh);
            }

            // populate table of summary statistics for measures
            Table res = new SummaryStatistics().process(tableRepets);
            resGlobal.setValue(iRadius, 0, radius);
            resGlobal.setValue(iRadius, 1, res.getValue(0, "Area"));
            resGlobal.setValue(iRadius, 2, res.getValue(2, "Area"));
            resGlobal.setValue(iRadius, 3, res.getValue(0, "Perimeter_ImageJ"));
            resGlobal.setValue(iRadius, 4, res.getValue(2, "Perimeter_ImageJ"));
            resGlobal.setValue(iRadius, 5, res.getValue(0, "Perimeter_Crofton2"));
            resGlobal.setValue(iRadius, 6, res.getValue(2, "Perimeter_Crofton2"));
            resGlobal.setValue(iRadius, 7, res.getValue(0, "Perimeter_Crofton4"));
            resGlobal.setValue(iRadius, 8, res.getValue(2, "Perimeter_Crofton4"));
            
            // populate table of summary statistics for relative errors
            Table resErrors = new SummaryStatistics().process(errorRepets);
            errorGlobal.setValue(iRadius,  0, radius);
            errorGlobal.setValue(iRadius,  1, resErrors.getValue(0, "Area"));
            errorGlobal.setValue(iRadius,  2, resErrors.getValue(2, "Area"));
            errorGlobal.setValue(iRadius,  3, resErrors.getValue(3, "Area"));
            errorGlobal.setValue(iRadius,  4, resErrors.getValue(4, "Area"));
            errorGlobal.setValue(iRadius,  5, resErrors.getValue(0, "Perimeter_ImageJ"));
            errorGlobal.setValue(iRadius,  6, resErrors.getValue(2, "Perimeter_ImageJ"));
            errorGlobal.setValue(iRadius,  7, resErrors.getValue(3, "Perimeter_ImageJ"));
            errorGlobal.setValue(iRadius,  8, resErrors.getValue(4, "Perimeter_ImageJ"));
            errorGlobal.setValue(iRadius,  9, resErrors.getValue(0, "Perimeter_Crofton2"));
            errorGlobal.setValue(iRadius, 10, resErrors.getValue(2, "Perimeter_Crofton2"));
            errorGlobal.setValue(iRadius, 11, resErrors.getValue(3, "Perimeter_Crofton2"));
            errorGlobal.setValue(iRadius, 12, resErrors.getValue(4, "Perimeter_Crofton2"));
            errorGlobal.setValue(iRadius, 13, resErrors.getValue(0, "Perimeter_Crofton4"));
            errorGlobal.setValue(iRadius, 14, resErrors.getValue(2, "Perimeter_Crofton4"));
            errorGlobal.setValue(iRadius, 15, resErrors.getValue(3, "Perimeter_Crofton4"));
            errorGlobal.setValue(iRadius, 16, resErrors.getValue(4, "Perimeter_Crofton4"));
        }
        
        
//        resGlobal.print(System.out);
//        System.out.println("");

        // Save result table
        File outputFile = new File("tables/perimeter_disk_R01to70_summary.txt");
        TableWriter writer = new DelimitedTableWriter(outputFile);
        writer.writeTable(resGlobal);
        
        // Save table of errors
        File outputFile2 = new File("tables/perimeter_disk_R01to70_error_summary.txt");
        TableWriter writer2 = new DelimitedTableWriter(outputFile2);
        writer2.writeTable(errorGlobal);
    }
}
