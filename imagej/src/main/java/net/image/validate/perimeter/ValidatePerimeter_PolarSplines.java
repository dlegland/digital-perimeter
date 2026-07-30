/**
 * 
 */
package net.image.validate.perimeter;

import java.io.File;
import java.io.IOException;

import ij.IJ;
import ij.ImageJ;
import ij.ImagePlus;
import ij.ImageStack;
import ij.measure.Calibration;
import ij.measure.Measurements;
import ij.measure.ResultsTable;
import ij.plugin.filter.ParticleAnalyzer;
import ij.process.ImageProcessor;
import ijt.table.Table;
import ijt.table.io.DelimitedTableWriter;
import ijt.table.io.TableWriter;
import inra.ijpb.measure.IntrinsicVolumes2D;

/**
 * Evaluates the accuracy of perimeter measurements on digital images obtained
 * from discretization of b-spline polygons.
 * 
 * For each shape, 1000 images are generated, with random position and
 * orientation with respect to the discretisation grid.
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
 * For each feature, the measurements over all repetitions are returned in a
 * data table saved in a text file within the "tables/polarsplines" directory of
 * the project.
 */
public class ValidatePerimeter_PolarSplines
{
    public static final int REPETITIONS = 1000;
        
    public static final void main(String... args) throws IOException
    {
        System.out.println("run validation of perimeter on spline polar polygons");

        @SuppressWarnings("unused")
        ImageJ imagejInstance = IJ.getInstance();

        File parentInputDir = new File("../matlab/perimeter/checkSampleShapes/polarSplines");

        // check base output Dir
        File parentOutputDir = new File("tables"); 
        if (!parentOutputDir.exists())
        {
            parentOutputDir.mkdir();
        }
        parentOutputDir = new File(parentOutputDir, "polarSplines"); 
        if (!parentOutputDir.exists())
        {
            parentOutputDir.mkdir();
        }
        parentOutputDir = new File(parentOutputDir, "polar8_R50");
        if (!parentOutputDir.exists())
        {
            parentOutputDir.mkdir();
        }

        // iterate over the generated synthetic data
        for (int index = 0; index < 50; index++)
        {
            //        int index = 1;

            File inputdir = new File(parentInputDir, String.format("polar8_%02d", index));
            String fileName = String.format("BSplinePolar8_R50_%d_stack.tif", index);
            
            System.out.println("process image: " + fileName);

            // read the stack containing the images
            File imageFile = new File(inputdir, fileName);
            ImagePlus imagePlus = IJ.openImage(imageFile.getPath());
            ImageStack stack = imagePlus.getStack();
            int nSlices = imagePlus.getStackSize();

            // create table for storing results
            String[] colNames = new String[] {"Area", "ImageJ", "Crofton2", "Crofton4"};
            Table resGlobal = Table.create(nSlices, colNames.length);
            resGlobal.setColumnNames(colNames);

            // iterate over images within the stack
            for (int iSlice = 0; iSlice < nSlices; iSlice++)
            {  
                //        int iSlice = 2;

                ImageProcessor slice = stack.getProcessor(iSlice + 1);
                ImagePlus slicePlus = new ImagePlus("slice" + iSlice, slice);
                IJ.setAutoThreshold(slicePlus, "Otsu dark");

                // compute perimeter using several methods
                ResultsTable resTable = new ResultsTable();
                int measurements = Measurements.AREA | Measurements.PERIMETER; 
                ParticleAnalyzer analyzer = new ParticleAnalyzer(0, measurements, resTable, 0.0, Double.POSITIVE_INFINITY);
                analyzer.analyze(slicePlus);

                double area = resTable.getValue("Area", 0);
                double perimIJ = resTable.getValue("Perim.", 0);
                double perimCrofton2 = IntrinsicVolumes2D.perimeter(slice, new Calibration(), 2);
                double perimCrofton4 = IntrinsicVolumes2D.perimeter(slice, new Calibration(), 4);

                if (iSlice == 0)
                {
                    System.out.println("Area = " + area + "  perimeter_IJ = " + perimIJ + "  perimeter_Crofton2 = " + perimCrofton2 + "  perimeter_Crofton4 = " + perimCrofton4);
                }
                resGlobal.setValue(iSlice, 0, area);
                resGlobal.setValue(iSlice, 1, perimIJ);
                resGlobal.setValue(iSlice, 2, perimCrofton2);
                resGlobal.setValue(iSlice, 3, perimCrofton4);
            }

            // Save result table
            File outputFile = new File(parentOutputDir, String.format("BSplinePolar8_R50_%02d.txt", index));
            TableWriter writer = new DelimitedTableWriter(outputFile);
            writer.writeTable(resGlobal);
        }
        System.out.println("done");
    }
}
