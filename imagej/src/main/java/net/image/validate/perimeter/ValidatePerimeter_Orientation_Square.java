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
import ij.process.ByteProcessor;
import ij.process.ImageProcessor;
import ijt.table.Table;
import ijt.table.io.DelimitedTableWriter;
import ijt.table.io.TableWriter;
import ijt.table.process.SummaryStatistics;
import inra.ijpb.measure.IntrinsicVolumes2D;
import net.ijt.geometry.polygon2d.OrientedBox2D;

/**
 * Evaluates the accuracy of perimeter measurements on a digital images of a
 * square with fixed size and varying rotation angle.
 * 
 * The square has a side length equal to 100 pixels, resulting in a theoretical
 * perimeter of 400 pixels. Rotation angles vary from 0 to 180 degrees, with a
 * step size of 0.5 degrees. For each rotation angle, 1000 images are generated,
 * with random position with respect to discretisation grid.
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
public class ValidatePerimeter_Orientation_Square
{
    public static final int REPETITIONS = 1000;
    
    public static final void fillBox(ImageProcessor image, OrientedBox2D box, double value)
    {
        // retrieve image size
        int sizeX = image.getWidth();
        int sizeY = image.getHeight();
        
        // iterate over image pixels
        for (int y = 0; y < sizeY; y++)
        {
            for (int x = 0; x < sizeX; x++)
            {
                if (box.isInside(x + 0.5, y + 0.5))
                {
                    image.setf(x, y, (float) value);
                }
            }
        }
    }
    
    public static final void main(String... args) throws IOException
    {
        System.out.println("run validation of perimeter on square for various orientations");
        
        int sideLength = 100;
        int sizeX = 200;
        int sizeY = 200;
            
        // theoretical values
        double areaTh = sideLength * sideLength;
        double perimTh = 4.0 * sideLength;

       @SuppressWarnings("unused")
        ImageJ imagejInstance = IJ.getInstance();
        
        double thetaMin = 0.0;
        double thetaMax = 180.0;
        double thetaStep = 0.5;
        
        // compute number of angles, keeping one for the value 180
        int nTheta = (int) Math.floor((thetaMax - thetaMin) / thetaStep) + 1;
        
        // create summary results tables
        Table resGlobal = Table.create(nTheta, 9);
        Table errorGlobal = Table.create(nTheta, 17);
        String[] colNames = new String[] {"Angle", "Area", "AreaStd", "ImageJ", "ImageJStd", "Crofton2", "Crofton2Std", "Crofton4", "Crofton4Std" };
        resGlobal.setColumnNames(colNames);
        String[] colNames2 = new String[] {
                "Angle", 
                "Area", "AreaStd", "AreaMin", "AreaMax", 
                "ImageJ", "ImageJStd", "ImageJMin", "ImageJMax", 
                "Crofton2", "Crofton2Std", "Crofton2Min", "Crofton2Max", 
                "Crofton4", "Crofton4Std", "Crofton4Min", "Crofton4Max"};
        errorGlobal.setColumnNames(colNames2);
        
        // iterate over angles
        for (int iTheta = 0; iTheta < nTheta; iTheta++)
        {
            double theta = iTheta * thetaStep + thetaMin;
            System.out.println(String.format(Locale.ENGLISH, "process theta %d/%d = %6.2f", iTheta, nTheta, theta));
            
            Table tableRepets = Table.create(REPETITIONS, 4);
            Table errorRepets = Table.create(REPETITIONS, 4);
            tableRepets.setColumnNames(new String[] {"Area", "Perimeter_ImageJ", "Perimeter_Crofton2", "Perimeter_Crofton4"});
            errorRepets.setColumnNames(new String[] {"Area", "Perimeter_ImageJ", "Perimeter_Crofton2", "Perimeter_Crofton4"});
            
            for (int iRepet = 0; iRepet < REPETITIONS; iRepet++)
            {
                // disk with random position around image center
                double centerX = sizeX / 2 + Math.random();
                double centerY = sizeY / 2 + Math.random();
                OrientedBox2D box = new OrientedBox2D(centerX, centerY, sideLength, sideLength, theta);

                ImageProcessor image = new ByteProcessor(sizeX, sizeY);
                fillBox(image, box, 255);

                ImagePlus imagePlus = new ImagePlus("Square", image);
                IJ.setAutoThreshold(imagePlus, "Otsu dark");


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
            resGlobal.setValue(iTheta, 0, theta);
            resGlobal.setValue(iTheta, 1, res.getValue(0, "Area"));
            resGlobal.setValue(iTheta, 2, res.getValue(2, "Area"));
            resGlobal.setValue(iTheta, 3, res.getValue(0, "Perimeter_ImageJ"));
            resGlobal.setValue(iTheta, 4, res.getValue(2, "Perimeter_ImageJ"));
            resGlobal.setValue(iTheta, 5, res.getValue(0, "Perimeter_Crofton2"));
            resGlobal.setValue(iTheta, 6, res.getValue(2, "Perimeter_Crofton2"));
            resGlobal.setValue(iTheta, 7, res.getValue(0, "Perimeter_Crofton4"));
            resGlobal.setValue(iTheta, 8, res.getValue(2, "Perimeter_Crofton4"));
            
            // populate table of summary statistics for relative errors
            Table resErrors = new SummaryStatistics().process(errorRepets);
            errorGlobal.setValue(iTheta,  0, theta);
            errorGlobal.setValue(iTheta,  1, resErrors.getValue(0, "Area"));
            errorGlobal.setValue(iTheta,  2, resErrors.getValue(2, "Area"));
            errorGlobal.setValue(iTheta,  3, resErrors.getValue(3, "Area"));
            errorGlobal.setValue(iTheta,  4, resErrors.getValue(4, "Area"));
            errorGlobal.setValue(iTheta,  5, resErrors.getValue(0, "Perimeter_ImageJ"));
            errorGlobal.setValue(iTheta,  6, resErrors.getValue(2, "Perimeter_ImageJ"));
            errorGlobal.setValue(iTheta,  7, resErrors.getValue(3, "Perimeter_ImageJ"));
            errorGlobal.setValue(iTheta,  8, resErrors.getValue(4, "Perimeter_ImageJ"));
            errorGlobal.setValue(iTheta,  9, resErrors.getValue(0, "Perimeter_Crofton2"));
            errorGlobal.setValue(iTheta, 10, resErrors.getValue(2, "Perimeter_Crofton2"));
            errorGlobal.setValue(iTheta, 11, resErrors.getValue(3, "Perimeter_Crofton2"));
            errorGlobal.setValue(iTheta, 12, resErrors.getValue(4, "Perimeter_Crofton2"));
            errorGlobal.setValue(iTheta, 13, resErrors.getValue(0, "Perimeter_Crofton4"));
            errorGlobal.setValue(iTheta, 14, resErrors.getValue(2, "Perimeter_Crofton4"));
            errorGlobal.setValue(iTheta, 15, resErrors.getValue(3, "Perimeter_Crofton4"));
            errorGlobal.setValue(iTheta, 16, resErrors.getValue(4, "Perimeter_Crofton4"));
        }
        
        
//        resGlobal.print(System.out);
//        System.out.println("");

        // Save result table
        File outputFile = new File("tables/perimeter_squareS100_byOrient_summary.txt");
        TableWriter writer = new DelimitedTableWriter(outputFile);
        writer.writeTable(resGlobal);
        
        // Save table of errors
        File outputFile2 = new File("tables/perimeter_squareS100_byOrient_error_summary.txt");
        TableWriter writer2 = new DelimitedTableWriter(outputFile2);
        writer2.writeTable(errorGlobal);
    }
}
